//
//  PrettyErrorPrinter.swift
//  EasyXConnect
//
//  Created by Shahanul Haque on 1/20/25.
//

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
            let components = [
                "❌ Data Corrupted Error",
                "------------------------",
                "Location: \(formatCodingPath(context.codingPath))",
                "Details: \(context.debugDescription)",
                "",
                "💡 Solution: Please verify the data format is valid"
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
    
    // Returns formatted error message without logging
    public static func prettyError(_ error: Error) -> String {
        if let decodingError = error as? DecodingError {
            return formatDecodingError(decodingError)
        } else {
            return ["❌ Error", "------------------------", error.localizedDescription].joined(separator: "\n")
        }
    }
    
    // Logs error using the configured log handler
    @MainActor public static func prettyPrint(_ error: Error) {
        defaultLogHandler(prettyError(error))
    }
    
    public init() {}
}

// Usage examples:
/*
// 1. Using custom logger
PrettyErrorPrinter.setLogHandler { message in
    Logger.error(message)  // Your logging system
}

// 2. Using print
PrettyErrorPrinter.setLogHandler { message in
    print(message)
}

// 3. Getting error string without logging
let errorMessage = PrettyErrorPrinter.prettyError(error)

// 4. Using with custom error handling
PrettyErrorPrinter.setLogHandler { message in
    // Send to analytics
    Analytics.logError(message)
    // Show in UI
    DispatchQueue.main.async {
        showErrorAlert(message)
    }
}
*/
