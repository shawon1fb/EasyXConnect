import Foundation

public class PrettyErrorPrinter {
    public typealias LogHandler = (String) -> Void
    
    // Default log handler that does nothing
    @MainActor private static var defaultLogHandler: LogHandler = { _ in }
    
    // Public method to set custom log handler
    @MainActor public static func setLogHandler(_ handler: @escaping LogHandler) {
        defaultLogHandler = handler
    }
    
    private static func formatCodingPath(_ codingPath: [CodingKey]) -> String {
        return codingPath.isEmpty ? "Root" : codingPath.map { $0.stringValue }.joined(separator: " → ")
    }
    
    private static func extractUnderlyingError(_ error: Error?) -> String {
        guard let underlyingError = error else { return "None" }
        
        // Handle NSError to extract UserInfo details
        let nsError = underlyingError as NSError
        var details = nsError.localizedDescription
        
        // Extract debug description from UserInfo if available
        if let debugDescription = nsError.userInfo["NSDebugDescription"] as? String {
            details += "\nDebug Info: \(debugDescription)"
        }
        
        return details
    }
    
    public static func formatDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, let context):
            let components = [
                "❌ Key Not Found Error",
                "------------------------",
                "Missing Key: \(key.stringValue)",
                "Location: \(formatCodingPath(context.codingPath))",
                "Details: \(context.debugDescription.replacingOccurrences(of: "No value associated with key", with: ""))",
                "",
                "💡 Solution: Please ensure the JSON contains the required key \"\(key.stringValue)\""
            ]
            return components.joined(separator: "\n")
            
        case .valueNotFound(let type, let context):
            let components = [
                "❌ Value Not Found Error",
                "------------------------",
                "Expected Type: \(type)",
                "Location: \(formatCodingPath(context.codingPath))",
                "Details: \(context.debugDescription)",
                "",
                "💡 Solution: Please check if the value is null or missing"
            ]
            return components.joined(separator: "\n")
            
        case .typeMismatch(let type, let context):
            let components = [
                "❌ Type Mismatch Error",
                "------------------------",
                "Expected Type: \(type)",
                "Location: \(formatCodingPath(context.codingPath))",
                "Details: \(context.debugDescription)",
                "",
                "💡 Solution: Please ensure the value matches the expected type"
            ]
            return components.joined(separator: "\n")
            
        case .dataCorrupted(let context):
            // Extract underlying error details if available
            let underlyingErrorDetails = extractUnderlyingError(context.underlyingError)
            
            var solution = "Please verify the data format is valid"
            
            // Customize solution based on common patterns
            if underlyingErrorDetails.contains("not representable in Swift") {
                solution = "Numeric value cannot be represented in the target Swift type. Check if you're trying to decode a floating-point number to an integer, or if the number exceeds the type's range."
            } else if underlyingErrorDetails.contains("not valid JSON") {
                solution = "The data isn't valid JSON. Verify the format and structure of your JSON."
            }
            
            let components = [
                "❌ Data Corrupted Error",
                "------------------------",
                "Location: \(formatCodingPath(context.codingPath))",
                "Details: \(context.debugDescription)",
                "Underlying Error: \(underlyingErrorDetails)",
                "",
                "💡 Solution: \(solution)"
            ]
            return components.joined(separator: "\n")
            
        @unknown default:
            let components = [
                "❌ Unknown Decoding Error",
                "------------------------",
                "Details: \(error.localizedDescription)",
                "",
                "💡 Solution: Please check the data structure and format"
            ]
            return components.joined(separator: "\n")
        }
    }
    
    // Extension to handle NSCocoaErrorDomain JSON parsing errors
    private static func formatNSCocoaError(_ error: NSError) -> String {
        let errorCode = error.code
        let userInfo = error.userInfo
        let debugDescription = userInfo["NSDebugDescription"] as? String ?? "No debug description available"
        
        var components = [
            "❌ JSON Parsing Error (Code: \(errorCode))",
            "------------------------",
            "Details: \(error.localizedDescription)",
            "Debug Info: \(debugDescription)",
            ""
        ]
        
        // Add specific solutions based on error codes and descriptions
        if errorCode == 3840 { // JSON parsing error
            if debugDescription.contains("not representable in Swift") {
                // Try to extract the problematic number from the error message
                var problematicValue = "unknown"
                if let regex = try? NSRegularExpression(pattern: "Number ([0-9.]+) is not", options: []),
                   let match = regex.firstMatch(in: debugDescription, options: [], range: NSRange(debugDescription.startIndex..., in: debugDescription)),
                   let numberRange = Range(match.range(at: 1), in: debugDescription) {
                    problematicValue = String(debugDescription[numberRange])
                }
                
                components.append("💡 Problem: A numeric value (\(problematicValue)) in your JSON can't be represented in Swift.")
                
                // If we know which field has the error (useful for your example)
                if let jsonData = userInfo["NSInvalidValue"] as? Data,
                   let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    
                    // Find keys with problematic values
                    let problematicKeys = json.filter { key, value in
                        "\(value)" == problematicValue
                    }.keys
                    
                    if !problematicKeys.isEmpty {
                        components.append("📍 Problematic JSON key(s): \(problematicKeys.joined(separator: ", "))")
                    }
                }
                
                components.append("💡 Solution:")
                components.append("  - Check if you're decoding a floating-point number (like \(problematicValue)) to an integer type")
                components.append("  - Ensure the number doesn't exceed the range of its target Swift type")
                components.append("  - Verify your model's property types match the JSON data types")
            } else {
                components.append("💡 Solution: The JSON data is malformed. Check the syntax and format.")
            }
        } else {
            components.append("💡 Solution: Please verify your JSON structure and format")
        }
        
        return components.joined(separator: "\n")
    }
    
    // Method to analyze a JSON string to find problematic values
    public static func analyzeJSON(_ jsonString: String, problematicValue: String) -> [String] {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }
        
        return findProblematicKeys(in: json, value: problematicValue)
    }
    
    // Recursively search for keys with a specific value
    private static func findProblematicKeys(in json: [String: Any], value: String, path: String = "") -> [String] {
        var result = [String]()
        
        for (key, val) in json {
            let currentPath = path.isEmpty ? key : "\(path).\(key)"
            
            // Convert the value to string and compare with our target
            let valueString = "\(val)"
            if valueString == value {
                result.append(currentPath)
            }
            
            // Recursively search in nested dictionaries
            if let nestedDict = val as? [String: Any] {
                result.append(contentsOf: findProblematicKeys(in: nestedDict, value: value, path: currentPath))
            }
            
            // Search in arrays
            if let array = val as? [Any] {
                for (index, item) in array.enumerated() {
                    let itemString = "\(item)"
                    if itemString == value {
                        result.append("\(currentPath)[\(index)]")
                    }
                    
                    if let nestedDict = item as? [String: Any] {
                        result.append(contentsOf: findProblematicKeys(in: nestedDict, value: value, path: "\(currentPath)[\(index)]"))
                    }
                }
            }
        }
        
        return result
    }
    
    // Helper function to find keys with numeric values that approximately match a target
    private static func findApproximateNumericKeys(in json: [String: Any], value: Double, path: String = "", epsilon: Double = 0.0001) -> [String] {
        var result = [String]()
        
        // Function to check if a value approximately matches our target
        func isApproximateMatch(_ testValue: Any) -> Bool {
            if let numValue = testValue as? NSNumber {
                let doubleVal = numValue.doubleValue
                // Check if they're very close (floating point comparison)
                return abs(doubleVal - value) < epsilon
            } else if let stringValue = testValue as? String, let doubleVal = Double(stringValue) {
                // Try to parse string as double
                return abs(doubleVal - value) < epsilon
            }
            // Convert to string and try matching that way
            let valueString = "\(testValue)"
            if let doubleVal = Double(valueString) {
                return abs(doubleVal - value) < epsilon
            }
            // Direct string comparison as fallback
            return valueString == "\(value)"
        }
        
        for (key, val) in json {
            let currentPath = path.isEmpty ? key : "\(path).\(key)"
            
            // Check for approximate match
            if isApproximateMatch(val) {
                result.append(currentPath)
            }
            
            // Recursively search in nested dictionaries
            if let nestedDict = val as? [String: Any] {
                result.append(contentsOf: findApproximateNumericKeys(in: nestedDict, value: value, path: currentPath, epsilon: epsilon))
            }
            
            // Search in arrays
            if let array = val as? [Any] {
                for (index, item) in array.enumerated() {
                    if isApproximateMatch(item) {
                        result.append("\(currentPath)[\(index)]")
                    }
                    
                    if let nestedDict = item as? [String: Any] {
                        result.append(contentsOf: findApproximateNumericKeys(in: nestedDict, value: value, path: "\(currentPath)[\(index)]", epsilon: epsilon))
                    }
                }
            }
        }
        
        return result
    }
    
    // Returns formatted error message without logging
    public static func prettyError(_ error: Error) -> String {
        if let decodingError = error as? DecodingError {
            return formatDecodingError(decodingError)
        } else {
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain {
                // Handle NSCocoaErrorDomain errors separately
                return formatNSCocoaError(nsError)
            } else {
                return ["❌ Error", "------------------------", error.localizedDescription].joined(separator: "\n")
            }
        }
    }
    
    // Logs error using the configured log handler
    @MainActor public static func prettyPrint(_ error: Error) {
        defaultLogHandler(prettyError(error))
    }
    
    // Improved method to extract and analyze a JSON problem in one step
    public static func analyzeJSONError(_ error: Error, jsonString: String) -> (String, [String]) {
        let formattedError = prettyError(error)
        var problematicKeys: [String] = []
        
        // Try to extract problematic value from error
        var problematicValue: String? = nil
        
        // Extract information from different error types
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .typeMismatch(_, let context),
                    .dataCorrupted(let context):
                // For type mismatch and data corrupted, check for underlying error
                if let underlyingError = context.underlyingError as NSError?,
                   let debugDescription = underlyingError.userInfo["NSDebugDescription"] as? String {
                    // Try to extract a number from the debug description
                    if debugDescription.contains("not representable in Swift") {
                        if let regex = try? NSRegularExpression(pattern: "Number ([0-9.]+) is not", options: []),
                           let match = regex.firstMatch(in: debugDescription, options: [], range: NSRange(debugDescription.startIndex..., in: debugDescription)),
                           let numberRange = Range(match.range(at: 1), in: debugDescription) {
                            problematicValue = String(debugDescription[numberRange])
                        }
                    }
                }
                
            case .keyNotFound(let key, _):
                // For key not found, we add the missing key to problematic keys
                problematicKeys.append(key.stringValue)
                
            case .valueNotFound(_, let context):
                // For value not found, we can at least report the path
                problematicKeys.append(formatCodingPath(context.codingPath))
                
            default:
                break
            }
        } else {
            // For other errors, check if it's a NSCocoaErrorDomain error
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain {
                let debugDescription = nsError.userInfo["NSDebugDescription"] as? String ?? ""
                
                if debugDescription.contains("not representable in Swift") {
                    if let regex = try? NSRegularExpression(pattern: "Number ([0-9.]+) is not", options: []),
                       let match = regex.firstMatch(in: debugDescription, options: [], range: NSRange(debugDescription.startIndex..., in: debugDescription)),
                       let numberRange = Range(match.range(at: 1), in: debugDescription) {
                        problematicValue = String(debugDescription[numberRange])
                    }
                }
            }
        }
        
        // If we found a problematic value, analyze the JSON
        if let value = problematicValue {
            let keys = analyzeJSON(jsonString, problematicValue: value)
            problematicKeys.append(contentsOf: keys)
            
            // If no keys found and value is numeric, try with approximate matching
            if problematicKeys.isEmpty, let _ = Double(value) {
                // Try to parse the JSON and apply approximate numeric matching
                do {
                    guard let data = jsonString.data(using: .utf8),
                          let _ = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        return (formattedError, problematicKeys)
                    }
                    
                    
                } catch {
                    // JSON is not parseable, can't find keys
                }
            }
        }
        
        return (formattedError, problematicKeys)
    }
    
   
    public init () {
        
    }
}

extension PrettyErrorPrinter{
    public static func prettyErrorFromJsonString(_ error: Error, jsonString: String) -> String {
        let (errorStr, keys) = analyzeJSONError(error, jsonString: jsonString)
        
        // If we found problematic keys, add them to the error message
        if !keys.isEmpty {
            var resultStr = errorStr
            
            // Add a section for problematic keys
            resultStr += "\n\n📍 Problematic JSON paths:"
            for key in keys {
                resultStr += "\n  - \(key)"
            }
            
//             Add a JSON structure preview
            if let data = jsonString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                resultStr += "\n\n📋 JSON Structure Preview:"
                let previewStr = captureJSONPreview(json)
                resultStr += "\n\(previewStr)"
            }
            
            return resultStr
        }
        
        return errorStr
    }

    // Helper method to generate a string representation of JSON structure
    private static func captureJSONPreview(_ json: Any, indent: String = "", maxDepth: Int = 2, currentDepth: Int = 0) -> String {
        var result = ""
        
        if currentDepth > maxDepth {
            return "\(indent)..."
        }
        
        if let dict = json as? [String: Any] {
            result += "\(indent){\n"
            let keys = dict.keys.sorted()
            for key in keys {
                let value = dict[key]!
                if let _ = value as? [String: Any], currentDepth < maxDepth {
                    result += "\(indent)  \(key): "
                    result += captureJSONPreview(value, indent: indent + "  ", maxDepth: maxDepth, currentDepth: currentDepth + 1)
                } else if let arrayValue = value as? [Any] {
                    result += "\(indent)  \(key): [Array with \(arrayValue.count) items]\n"
                } else {
                    let valueStr = String(describing: value).prefix(50)
                    result += "\(indent)  \(key): \(valueStr)\(valueStr.count >= 50 ? "..." : "")\n"
                }
            }
            result += "\(indent)}\n"
        } else if let array = json as? [Any] {
            result += "\(indent)[\n"
            if !array.isEmpty {
                if array.count <= 3 {
                    for item in array {
                        result += captureJSONPreview(item, indent: indent + "  ", maxDepth: maxDepth, currentDepth: currentDepth + 1)
                    }
                } else {
                    result += captureJSONPreview(array[0], indent: indent + "  ", maxDepth: maxDepth, currentDepth: currentDepth + 1)
                    result += "\(indent)  ... (\(array.count - 2) more items) ...\n"
                    result += captureJSONPreview(array.last!, indent: indent + "  ", maxDepth: maxDepth, currentDepth: currentDepth + 1)
                }
            }
            result += "\(indent)]\n"
        } else {
            let valueStr = String(describing: json).prefix(50)
            result += "\(indent)\(valueStr)\(valueStr.count >= 50 ? "..." : "")\n"
        }
        
        return result
    }
}
