//
//  DTOTests.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//

import XCTest
@testable import EasyXConnect  // Replace with your actual module name

struct TestDTO: DTO {
    let name: String
    let age: Int
    let isActive: Bool
}

class DTOTests: XCTestCase {

    // Test toJsonMap() method
    func testToJsonMap() {
        let dto = TestDTO(name: "John Doe", age: 1, isActive: true)
        let jsonMap = dto.toJsonMap()

        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["name"]?.value as? String, "John Doe")
        XCTAssertEqual(jsonMap?["age"]?.value as? Int, 1)
        XCTAssertEqual(jsonMap?["isActive"]?.value as? Bool, true)
    }

    // Test toData() method
    func testToData() {
        let dto = TestDTO(name: "John Doe", age: 30, isActive: true)
        let data = dto.toData()

        XCTAssertNotNil(data)

        // Decode the data back into a dictionary
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
        XCTAssertEqual(json?["name"] as? String, "John Doe")
        XCTAssertEqual(json?["age"] as? Int, 30)
        XCTAssertEqual(json?["isActive"] as? Bool, true)
    }

    // Test toString() method
    func testToString() {
        let dto = TestDTO(name: "John Doe", age: 30, isActive: true)
        let jsonString = dto.toString()

        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString.contains("\"name\":\"John Doe\""))
        XCTAssertTrue(jsonString.contains("\"age\":30"))
        XCTAssertTrue(jsonString.contains("\"isActive\":true"))
    }

    // Test toQueryParams() method
    func testToQueryParams() {
        let dto = TestDTO(name: "John Doe", age: 1, isActive: true)
        let queryParams = dto.toQueryParams()
        
        XCTAssertNotNil(queryParams)
        XCTAssertEqual(queryParams?["name"], "John Doe")
        XCTAssertEqual(queryParams?["age"], "1")
        XCTAssertEqual(queryParams?["isActive"], "true")
    }

    // Test handling of optional fields
    func testOptionalHandling() {
        struct OptionalDTO: DTO {
            let name: String?
            let age: Int?
        }

        let dto = OptionalDTO(name: nil, age: 1)
        let jsonMap = dto.toJsonMap()

        XCTAssertNotNil(jsonMap)
        XCTAssertNil(jsonMap?["name"]?.value)
        XCTAssertEqual(jsonMap?["age"]?.value as? Int, 1)
    }

    // Test handling of non-encodable fields
    func testNonEncodableFieldHandling() {
        struct NonEncodableDTO: DTO {
            let name: String
            let nonEncodable: Any
            
            enum CodingKeys: String, CodingKey {
                  case name
              }
        }

        let dto = NonEncodableDTO(name: "John", nonEncodable: NSObject())
        let jsonMap = dto.toJsonMap()

        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["name"]?.value as? String, "John")
        XCTAssertNotNil(jsonMap?["nonEncodable"]) // Should be encoded as a string description
    }
    
    
}
