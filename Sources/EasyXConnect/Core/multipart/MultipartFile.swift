//
//  MultipartFile.swift
//
//
//  Created by shahanul on 24/2/24.
//
import Foundation
import UniformTypeIdentifiers
import MobileCoreServices

public struct MultipartFile {
    let data: Data
    let filename: String
    let contentType: String
}

extension URL{
    public func toMultipartFile() -> MultipartFile? {
        do {
            // Read file data from URL
            let data = try Data(contentsOf: self)
            
            // Extract filename from URL
            let filename = lastPathComponent
            
            // Determine content type based on file extension
            var contentType = "application/octet-stream"
            
//            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
//               let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
//                contentType = mimetype as String
//            }
            if #available(iOS 14.0, *) {
                if let typeIdentifier = UTType(filenameExtension: pathExtension)?.identifier,
                   let mimeType = UTType(typeIdentifier)?.preferredMIMEType {
                    contentType = mimeType
                }
            } else {
                // Fallback on earlier versions
                if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
                   let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                    contentType = mimetype as String
                }
            }
            
            
            return MultipartFile(data: data, filename: filename, contentType: contentType)
        } catch {
            print("Error creating MultipartFile: \(error)")
            return nil
        }
    }
}

public struct FormData {
    private static let maxBoundaryLength = 70
    private static let boundaryCharacters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    
    public static func generateBoundary() -> String {
        let randomBoundary = String((0..<maxBoundaryLength).map { _ in boundaryCharacters.randomElement()! })
        return "----WebKitFormBoundary\(randomBoundary)"
    }
    
    let boundary: String
    var fields = [(String, String)]()
    var files = [(String, MultipartFile)]()
    
    public init(map: [String: AnyEncodable?] , boundary:String ) {
        self.boundary = boundary //FormData.generateBoundary()
        
        map.forEach { key, value in
            guard let value = value?.value else { return }
            
            if let file = value as? URL {
                if let multipartFile = file.toMultipartFile(){
                    files.append((key, multipartFile))
                }
                
            } else if let filesArray = value as? [URL] {
                for url in filesArray{
                    if let file = url.toMultipartFile(){
                        files.append((key, file))
                    }
                }
                
            } else if let valuesArray = value as? [Any] {
                valuesArray.forEach { fields.append((key, String(describing: $0))) }
            } else {
                fields.append((key, String(describing: value)))
            }
        }
    }
    
    
    public func toBytes() -> Data? {
        var data = Data()
        
        // Start building the multipart form data
        let boundaryPrefix = "--\(boundary)\r\n"
        
        // Add fields data
        for field in fields {
            data.append(boundaryPrefix.data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(field.0)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(field.1)\r\n".data(using: .utf8)!)
        }
        
        // Add files data
        for file in files {
            data.append(boundaryPrefix.data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(file.0)\"; filename=\"\(file.1.filename)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(file.1.contentType)\r\n\r\n".data(using: .utf8)!)
            data.append(file.1.data)
            data.append("\r\n".data(using: .utf8)!)
        }
        
        // Add the final boundary indicating the end of the multipart form data
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
    
}

// Example usage:
//let formData = FormData(map: ["key1": "value1", "key2": 123, "file1": MultipartFile(data: Data("file1content".utf8), filename: "example.txt", contentType: "text/plain")])
//
//let data = formData.toBytes()
//print(data.count)
