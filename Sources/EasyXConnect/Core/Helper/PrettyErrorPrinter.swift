//
//  PrettyErrorPrinter.swift
//  EasyXConnect
//
//  Created by Shahanul Haque on 1/20/25.
//
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
                components.append("💡 Solution: A numeric value in your JSON can't be represented in Swift. This happens when:")
                components.append("  - A floating-point number (like 451.5) is being decoded to an integer type")
                components.append("  - A number exceeds the range of its target Swift type")
                components.append("  - Check your model's property types and ensure they match the JSON data types")
            } else {
                components.append("💡 Solution: The JSON data is malformed. Check the syntax and format.")
            }
        } else {
            components.append("💡 Solution: Please verify your JSON structure and format")
        }
        
        return components.joined(separator: "\n")
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
    
    public init() {}
}
