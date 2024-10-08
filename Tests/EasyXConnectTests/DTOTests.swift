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
    
    // Test nested DTOs
    func testNestedDTO() {
        struct InnerDTO: DTO {
            let innerName: String
            let innerValue: Int
        }

        struct OuterDTO: DTO {
            let outerName: String
            let innerDTO: InnerDTO
        }

        let inner = InnerDTO(innerName: "Inner", innerValue: 42)
        let outer = OuterDTO(outerName: "Outer", innerDTO: inner)

        let jsonMap = outer.toJsonMap()

        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["outerName"]?.value as? String, "Outer")

        if let innerEncodable = jsonMap?["innerDTO"]?.value as? InnerDTO {
            XCTAssertEqual(innerEncodable.innerName, "Inner")
            XCTAssertEqual(innerEncodable.innerValue, 42)
        } else {
            XCTFail("innerDTO is not properly encoded")
        }
    }

    // Test arrays of DTOs
    func testArrayOfDTOs() {
        struct ItemDTO: DTO {
            let id: Int
            let value: String
        }

        struct CollectionDTO: DTO {
            let items: [ItemDTO]
        }

        let items = [
            ItemDTO(id: 1, value: "Item1"),
            ItemDTO(id: 2, value: "Item2")
        ]
        let dto = CollectionDTO(items: items)
        let jsonMap = dto.toJsonMap()

        XCTAssertNotNil(jsonMap)
        if let itemsArray = jsonMap?["items"]?.value as? [ItemDTO] {
            XCTAssertEqual(itemsArray.count, 2)
            XCTAssertEqual(itemsArray[0].id, 1)
            XCTAssertEqual(itemsArray[0].value, "Item1")
            XCTAssertEqual(itemsArray[1].id, 2)
            XCTAssertEqual(itemsArray[1].value, "Item2")
        } else {
            XCTFail("items are not properly encoded")
        }
    }

    // Test custom CodingKeys
    func testCustomCodingKeys() {
        struct CustomKeysDTO: DTO {
            let firstName: String
            let lastName: String

            enum CodingKeys: String, CodingKey {
                case firstName = "first_name"
                case lastName = "last_name"
            }
        }

        let dto = CustomKeysDTO(firstName: "John", lastName: "Doe")
        let jsonMap = dto.toJsonMap()

        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["first_name"]?.value as? String, "John")
        XCTAssertEqual(jsonMap?["last_name"]?.value as? String, "Doe")
        XCTAssertNil(jsonMap?["firstName"])
        XCTAssertNil(jsonMap?["lastName"])
    }

    // Test handling of Date properties
    func testDateHandling() {
        struct DateDTO: DTO {
            let date: Date
        }

        let date = Date(timeIntervalSince1970: 0) // Jan 1, 1970
        let dto = DateDTO(date: date)
        let jsonMap = dto.toJsonMap()

       
        XCTAssertNotNil(jsonMap)
        XCTAssertNotNil(jsonMap?["date"]?.value)
        XCTAssertEqual(jsonMap?["date"]?.value as? Date, date)

        // Verify that the date is correctly encoded
        let data = dto.toData()
        XCTAssertNotNil(data)
        let decodedJSON = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
        print(decodedJSON ?? [:])
        XCTAssertNotNil(decodedJSON)
        XCTAssertNotNil(decodedJSON?["date"])
    }

    // Test DTO with enum properties
    func testEnumPropertyDTO() {
        struct EnumDTO: DTO {
            enum Status: String, Codable {
                case active
                case inactive
                case unknown
            }

            let status: Status
        }

        let dto = EnumDTO(status: .active)
        let jsonMap = dto.toJsonMap()
        print(jsonMap ?? [:])
        print(dto.toString())
        print(jsonMap?["status"]?.value ?? "")
        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["status"]?.value as? String, "active")
//        XCTAssertEqual(jsonMap?["status"]?.value, EnumDTO.Status.active)
    }

    // Test optional properties with nil and non-nil values
    func testOptionalPropertiesNilAndNonNil() {
        struct OptionalDTO: DTO {
            let name: String?
            let age: Int?
        }

        // All properties nil
        let dtoNil = OptionalDTO(name: nil, age: nil)
        let jsonMapNil = dtoNil.toJsonMap()
        XCTAssertNil(jsonMapNil)

        // Some properties nil
        let dtoPartial = OptionalDTO(name: "John", age: nil)
        let jsonMapPartial = dtoPartial.toJsonMap()
        XCTAssertNotNil(jsonMapPartial)
        XCTAssertEqual(jsonMapPartial?["name"]?.value as? String, "John")
        XCTAssertNil(jsonMapPartial?["age"])

        // No properties nil
        let dtoFull = OptionalDTO(name: "John", age: 30)
        let jsonMapFull = dtoFull.toJsonMap()
        XCTAssertNotNil(jsonMapFull)
        XCTAssertEqual(jsonMapFull?["name"]?.value as? String, "John")
        XCTAssertEqual(jsonMapFull?["age"]?.value as? Int, 30)
    }

    // Test DTO with dictionary property
    func testDictionaryPropertyDTO() {
        struct DictionaryDTO: DTO {
            let dict: [String: Int]
        }

        let dto = DictionaryDTO(dict: ["one": 1, "two": 2])
        let jsonMap = dto.toJsonMap()

        XCTAssertNotNil(jsonMap)
        if let dictValue = jsonMap?["dict"]?.value as? [String: Int] {
            XCTAssertEqual(dictValue["one"], 1)
            XCTAssertEqual(dictValue["two"], 2)
        } else {
            XCTFail("Dictionary is not properly encoded")
        }
    }

    // Test handling of URL properties
    func testURLPropertyDTO() {
        struct URLDTO: DTO {
            let url: URL
        }

        let dto = URLDTO(url: URL(string: "https://example.com")!)
        let jsonMap = dto.toJsonMap()
        
        print(jsonMap ?? [:])
        print(dto.toString())
       
        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["url"]?.value as? String, "https://example.com")
    }

    // Test properties with custom encoding logic
    func testCustomEncodableProperty() {
        struct CustomType: Encodable,Equatable {
            let value: String

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode("Custom: \(value)")
            }
        }

        struct CustomDTO: DTO {
            let custom: CustomType
        }

        let customValue = CustomType(value: "Test")
        let dto = CustomDTO(custom: customValue)
        let jsonMap = dto.toJsonMap()
        print(jsonMap ?? [:])
        print(dto.toString())
        XCTAssertNotNil(jsonMap)
        XCTAssertEqual(jsonMap?["custom"]?.value as? CustomType, customValue)
    }

    // Test toString() produces valid JSON
    func testToStringProducesValidJSON() {
        let dto = TestDTO(name: "John Doe", age: 30, isActive: true)
        let jsonString = dto.toString()

        XCTAssertNotNil(jsonString)
        let data = jsonString.data(using: .utf8)!
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
        XCTAssertNotNil(jsonObject)
        if let jsonDict = jsonObject as? [String: Any] {
            XCTAssertEqual(jsonDict["name"] as? String, "John Doe")
            XCTAssertEqual(jsonDict["age"] as? Int, 30)
            XCTAssertEqual(jsonDict["isActive"] as? Bool, true)
        } else {
            XCTFail("JSON string did not produce a dictionary")
        }
    }

    // Test handling of properties with null values
    func testPropertiesWithNullValues() {
        struct NullValuesDTO: DTO {
            let name: String?
            let age: Int?
            let isActive: Bool?
        }

        let dto = NullValuesDTO(name: nil, age: nil, isActive: nil)
        let jsonMap = dto.toJsonMap()

        XCTAssertNil(jsonMap)

        let dto2 = NullValuesDTO(name: "John", age: nil, isActive: nil)
        let jsonMap2 = dto2.toJsonMap()
        XCTAssertNotNil(jsonMap2)
        XCTAssertEqual(jsonMap2?["name"]?.value as? String, "John")
        XCTAssertNil(jsonMap2?["age"])
        XCTAssertNil(jsonMap2?["isActive"])
    }

    // Test encoding failure handling
    func testEncodingFailure() {
        struct NonEncodable: Encodable {
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "TestError", code: 1, userInfo: nil)
            }
        }

        struct FaultyDTO: DTO {
            let nonEncodable: NonEncodable
        }

        let dto = FaultyDTO(nonEncodable: NonEncodable())
        let data = dto.toData()
        XCTAssertNil(data)
    }

    // Test toQueryParams() with complex types
    func testToQueryParamsComplexTypes() {
        struct QueryDTO: DTO {
            let name: String
            let age: Int
            let isActive: Bool
            let scores: [Int]
            let tags: [String]
        }

        let dto = QueryDTO(name: "John", age: 30, isActive: true, scores: [1, 2, 3], tags: ["a", "b"])
        let queryParams = dto.toQueryParams()

        XCTAssertNotNil(queryParams)
        XCTAssertEqual(queryParams?["name"], "John")
        XCTAssertEqual(queryParams?["age"], "30")
        XCTAssertEqual(queryParams?["isActive"], "true")
        XCTAssertEqual(queryParams?["scores"], "[1, 2, 3]")
        XCTAssertEqual(queryParams?["tags"], "[\"a\", \"b\"]")
    }
}
