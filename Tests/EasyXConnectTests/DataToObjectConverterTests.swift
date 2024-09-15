//
//  DataToObjectConverterTests.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//
import XCTest

// Assuming the AppResponse and DataToObjectConverter are in the same module
@testable import EasyXConnect

final class DataToObjectConverterTests: XCTestCase {

    // 1. Test when R is Data
    func testDataToObject_withDataType() throws {
        let mockData = "Test Data".data(using: .utf8)!
        let statusCode = 200
        
        let response = try DataToObjectConverter.dataToObject(data: mockData, statusCode: statusCode) as AppResponse<Data>
        
        XCTAssertEqual(response.statusCode, statusCode)
        XCTAssertEqual(response.payload, mockData)
        XCTAssertTrue(response.success)
    }
    
    // 2. Test when R is String
    func testDataToObject_withStringType() throws {
        let mockString = "Test String"
        let mockData = mockString.data(using: .utf8)!
        let statusCode = 200
        
        let response = try DataToObjectConverter.dataToObject(data: mockData, statusCode: statusCode) as AppResponse<String>
        
        XCTAssertEqual(response.statusCode, statusCode)
        XCTAssertEqual(response.payload, mockString)
        XCTAssertTrue(response.success)
    }

    // 3. Test when R is a Decodable struct
    struct MockResponse: Codable, Equatable {
        let id: Int
        let message: String
    }

    func testDataToObject_withDecodableType() throws {
        let mockResponse = MockResponse(id: 1, message: "Success")
        let mockData = try JSONEncoder().encode(mockResponse)
        let statusCode = 200
        
        let response = try DataToObjectConverter.dataToObject(data: mockData, statusCode: statusCode) as AppResponse<MockResponse>
        
        XCTAssertEqual(response.statusCode, statusCode)
        XCTAssertEqual(response.payload, mockResponse)
        XCTAssertTrue(response.success)
    }

    // 4. Test when R is invalid JSON (failure case)
    func testDataToObject_withInvalidJSON() {
        let invalidJSON = "Invalid JSON".data(using: .utf8)!
        let statusCode = 400
        
        XCTAssertThrowsError(try DataToObjectConverter.dataToObject(data: invalidJSON, statusCode: statusCode) as AppResponse<MockResponse>) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}


