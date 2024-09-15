//
//  FieldNameTests.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//
import XCTest

// Assuming FieldName is part of the module you're testing
@testable import EasyXConnect

class FieldNameTests: XCTestCase {
    
    struct TestDTO: DTO {
        @FieldName(key: "string_key")
        var stringField: String = "Hello"
        
        @FieldName(key: "int_key")
        var intField: Int = 42
        
        @FieldName(key: "optional_key")
        var optionalField: String? = nil
        
        @FieldName(key: "array_key")
        var arrayField: [Int] = [1, 2, 3]
        
        var normalField: Double = 3.14
    }
    
    func testToJsonMap() {
        let dto = TestDTO()
        let jsonMap = dto.toJsonMap()
        
        print("--------------------------------------------")
        print("\(jsonMap ?? [:])")
        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["string_key"]?.value as? String, "Hello")
        XCTAssertEqual(jsonMap?["int_key"]?.value as? Int, 42)
        XCTAssertNil(jsonMap?["optional_key"])
        XCTAssertEqual(jsonMap?["array_key"]?.value as? [Int], [1, 2, 3])
        XCTAssertEqual(jsonMap?["normalField"]?.value as? Double, 3.14)
    }
    
    func testToJsonMapWithOptional() {
        var dto = TestDTO()
        dto.optionalField = "Present"
        let jsonMap = dto.toJsonMap()
        
        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["optional_key"]?.value as? String, "Present")
    }
    
    func testToData() {
        let dto = TestDTO()
        let data = dto.toData()
        
        XCTAssertNotNil(data)
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            XCTAssertEqual(jsonObject["string_key"] as? String, "Hello")
            XCTAssertEqual(jsonObject["int_key"] as? Int, 42)
            XCTAssertNil(jsonObject["optional_key"])
            XCTAssertEqual(jsonObject["array_key"] as? [Int], [1, 2, 3])
            XCTAssertEqual(jsonObject["normalField"] as? Double, 3.14)
        } else {
            XCTFail("Failed to parse JSON data")
        }
    }
    
    func testToQueryParams() {
        let dto = TestDTO()
        let queryParams = dto.toQueryParams()
        
        XCTAssertNotNil(queryParams)
        XCTAssertEqual(queryParams?["string_key"], "Hello")
        XCTAssertEqual(queryParams?["int_key"], "42")
        XCTAssertNil(queryParams?["optional_key"])
        XCTAssertEqual(queryParams?["array_key"], "[1, 2, 3]")
        XCTAssertEqual(queryParams?["normalField"], "3.14")
    }
    
    func testEncoding() {
        let dto = TestDTO()
       
        do {
            let encodedData = dto.toData()
            guard let encodedData = encodedData else {
                XCTFail("Failed to convert encoded data to string")
                return
            }
            let jsonObject = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any]
            
            XCTAssertNotNil(jsonObject)
            XCTAssertEqual(jsonObject?["string_key"] as? String, "Hello")
            XCTAssertEqual(jsonObject?["int_key"] as? Int, 42)
            XCTAssertNil(jsonObject?["optional_key"])
            XCTAssertEqual(jsonObject?["array_key"] as? [Int], [1, 2, 3])
            XCTAssertEqual(jsonObject?["normalField"] as? Double, 3.14)
        } catch {
            XCTFail("Encoding failed: \(error)")
        }
    }
    
    func testAnyEncodable() {
        let value: Encodable = "Test"
        let anyEncodable = AnyEncodable(value)
        let encoder = JSONEncoder()
        
        do {
            let encodedData = try encoder.encode(anyEncodable)
            let decodedString = String(data: encodedData, encoding: .utf8)
            XCTAssertEqual(decodedString, "\"Test\"")
        } catch {
            XCTFail("AnyEncodable encoding failed: \(error)")
        }
    }
}
