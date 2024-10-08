import XCTest

@testable import EasyXConnect 
// Sample Encodable struct for testing
struct SampleStruct: Encodable {
    var name: String
    var age: Int
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case name = "full_name"
        case age
        case isActive = "is_active"
    }
}

class CodingKeysFinderTests: XCTestCase {

    func testCollectCodingKeys() {
        let sample = SampleStruct(name: "Alice", age: 28, isActive: true)
        let collectedKeys = CodingKeysFinder.collectCodingKeys(from: sample)
        let expectedKeys = ["full_name", "age", "is_active"]

        XCTAssertEqual(
            Set(collectedKeys),
            Set(expectedKeys),
            "Collected keys do not match expected keys."
        )
    }

    func testCollectCodingKeysValue() {
        let sample = SampleStruct(name: "Alice", age: 28, isActive: true)
        let collectedKeyValues = CodingKeysFinder.collectCodingKeysValue(from: sample)
        let expectedKeyValues: [String: String] = [
            "name": "full_name",
            "age": "age",
            "isActive": "is_active"
        ]

        XCTAssertEqual(
            collectedKeyValues,
            expectedKeyValues,
            "Collected key-value pairs do not match expected pairs."
        )
    }

    func testCollectCodingKeysWithDefaultCodingKeys() {
        struct DefaultCodingKeysStruct: Encodable {
            var title: String
            var description: String
        }

        let sample = DefaultCodingKeysStruct(title: "Test Title", description: "Test Description")
        let collectedKeys = CodingKeysFinder.collectCodingKeys(from: sample)
        let expectedKeys = ["title", "description"]

        XCTAssertEqual(
            Set(collectedKeys),
            Set(expectedKeys),
            "Collected keys should match property names when no custom CodingKeys are provided."
        )
    }

    func testCollectCodingKeysValueWithDefaultCodingKeys() {
        struct DefaultCodingKeysStruct: Encodable {
            var title: String
            var description: String
        }

        let sample = DefaultCodingKeysStruct(title: "Test Title", description: "Test Description")
        let collectedKeyValues = CodingKeysFinder.collectCodingKeysValue(from: sample)
        let expectedKeyValues: [String: String] = [
            "title": "title",
            "description": "description"
        ]

        XCTAssertEqual(
            collectedKeyValues,
            expectedKeyValues,
            "Collected key-value pairs should match property names when no custom CodingKeys are provided."
        )
    }

    func testNestedStructs() {
        struct NestedStruct: Encodable {
            var id: Int
            var nested: SampleStruct

            enum CodingKeys: String, CodingKey {
                case id
                case nested = "nested_struct"
            }
        }

        let nestedSample = SampleStruct(name: "Bob", age: 35, isActive: false)
        let sample = NestedStruct(id: 1, nested: nestedSample)
        let collectedKeys = CodingKeysFinder.collectCodingKeys(from: sample)
        let expectedKeys = ["id", "nested_struct"]

        XCTAssertEqual(
            Set(collectedKeys),
            Set(expectedKeys),
            "Collected keys for nested structs do not match expected keys."
        )
    }

    func testEncodingErrorHandling() {
        struct FaultyStruct: Encodable {
            var value: String

            func encode(to encoder: Encoder) throws {
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Forced error"))
            }
        }

        let sample = FaultyStruct(value: "Error")
        let collectedKeys = CodingKeysFinder.collectCodingKeys(from: sample)

        XCTAssertTrue(
            collectedKeys.isEmpty,
            "Collected keys should be empty when encoding fails."
        )
    }
}
