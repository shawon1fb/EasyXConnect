//
//  FormDataTests.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//

import XCTest
@testable import EasyXConnect

final class FormDataTests: XCTestCase {

    func testFormDataFields() throws {
        // Arrange
        let testMap: [String: AnyEncodable?] = [
            "field1": AnyEncodable("value1"),
            "field2": AnyEncodable(123),
            "field3": AnyEncodable([1, 2, 3])
        ]
        
        let boundary = FormData.generateBoundary()
        let formData = FormData(map: testMap, boundary: boundary)
        
        // Act
        let formDataBytes = formData.toBytes()
        
        // Assert
        XCTAssertNotNil(formDataBytes, "Form data should not be nil")
        
        let formDataString = String(data: formDataBytes!, encoding: .utf8)
        XCTAssertTrue(formDataString?.contains("name=\"field1\"") ?? false, "Form data should contain field1")
        XCTAssertTrue(formDataString?.contains("value1") ?? false, "Form data should contain value1")
        XCTAssertTrue(formDataString?.contains("name=\"field2\"") ?? false, "Form data should contain field2")
        XCTAssertTrue(formDataString?.contains("123") ?? false, "Form data should contain value for field2")
    }

    func testFormDataFiles() throws {
        // Arrange
//        let testFileUrl = URL(fileURLWithPath: "/path/to/your/file.txt")
        guard let testFileUrl = getLocalFileURL(filename: "file.txt") else {
            XCTFail("file.txt not found")
            return
        }
        let testMap: [String: AnyEncodable?] = [
            "fileField": AnyEncodable(testFileUrl)
        ]
        
        let boundary = FormData.generateBoundary()
        let formData = FormData(map: testMap, boundary: boundary)
        
        // Act
        let formDataBytes = formData.toBytes()
        
        // Assert
        XCTAssertNotNil(formDataBytes, "Form data should not be nil")
        
        let formDataString = String(data: formDataBytes!, encoding: .utf8)
        XCTAssertTrue(formDataString?.contains("name=\"fileField\"") ?? false, "Form data should contain fileField")
        XCTAssertTrue(formDataString?.contains("filename=\"file.txt\"") ?? false, "Form data should contain the file name")
        XCTAssertTrue(formDataString?.contains("Content-Type: application/octet-stream") ?? false, "Form data should contain content type for the file")
    }
    
    func testGenerateBoundary() throws {
        // Arrange & Act
        let boundary = FormData.generateBoundary()
        
        // Assert
        XCTAssertFalse(boundary.isEmpty, "Generated boundary should not be empty")
        XCTAssertTrue(boundary.starts(with: "----WebKitFormBoundary"), "Boundary should start with the correct prefix")
    }
    
    func testReadLocalFile() throws {
            // Arrange
            guard let fileURL = getLocalFileURL(filename: "file.txt") else {
                XCTFail("Failed to locate file.txt in the test directory")
                return
            }

            // Act
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            
            // Assert
            XCTAssertFalse(fileContent.isEmpty, "file.txt should not be empty")
            print("File Content: \(fileContent)")  // Just to print out the file content (optional)
        }

        // Helper function to get the URL of file.txt in the same directory as FormDataTests.swift
        func getLocalFileURL(filename: String) -> URL? {
            let fileManager = FileManager.default
            let currentDirectory = URL(fileURLWithPath: #file).deletingLastPathComponent()
            let fileURL = currentDirectory.appendingPathComponent(filename)
            
            if fileManager.fileExists(atPath: fileURL.path) {
                return fileURL
            } else {
                return nil
            }
        }

        // Example test that uses the file
        func testFormDataFilesWithLocalFile() throws {
            // Arrange
            guard let testFileUrl = getLocalFileURL(filename: "file.txt") else {
                XCTFail("file.txt not found")
                return
            }

            let testMap: [String: AnyEncodable?] = [
                "fileField": AnyEncodable(testFileUrl)
            ]
            
            let boundary = FormData.generateBoundary()
            let formData = FormData(map: testMap, boundary: boundary)
            
            // Act
            let formDataBytes = formData.toBytes()
            
            // Assert
            XCTAssertNotNil(formDataBytes, "Form data should not be nil")
            
            let formDataString = String(data: formDataBytes!, encoding: .utf8)
            XCTAssertTrue(formDataString?.contains("name=\"fileField\"") ?? false, "Form data should contain fileField")
            XCTAssertTrue(formDataString?.contains("filename=\"file.txt\"") ?? false, "Form data should contain the file name")
            XCTAssertTrue(formDataString?.contains("Content-Type: application/octet-stream") ?? false, "Form data should contain content type for the file")
        }
}

