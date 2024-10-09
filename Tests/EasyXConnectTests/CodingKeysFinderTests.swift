import XCTest

@testable import EasyXConnect 
// Sample Encodable struct for testing
struct SampleStruct: Encodable {
    var name: String
    var age: Int
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case name = "full_name"
        case isActive = "is_active"
        case age
        
    }
}
struct SubmitReviewRequestBody: DTO {
    let productId, rating, description: String?
    let contents: [MediaContentResponse]?

    enum CodingKeys: String, CodingKey {
        case rating, description, contents, productId
    }
}

public struct MediaContentResponse: Codable, Equatable {
  public let url: String?
  public let mimeType: String?
  public let altText: String?
  public let thumbnail: String?
  public let autoplay, autoRepeat: Bool?
  public let duration: Double?
  public let contentPlatform: String?

  public init(
    url: String? = nil,
    mimeType: String?,
    altText: String? = nil,
    thumbnail: String? = nil,
    autoplay: Bool? = nil,
    autoRepeat: Bool? = nil,
    duration: Double? = nil,
    contentPlatform: String? = nil
  ) {
    self.url = url
    self.mimeType = mimeType
    self.altText = altText
    self.thumbnail = thumbnail
    self.autoplay = autoplay
    self.autoRepeat = autoRepeat
    self.duration = duration
    self.contentPlatform = contentPlatform
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.url = try container.decodeIfPresent(String.self, forKey: .url)
    self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
    self.altText = try container.decodeIfPresent(String.self, forKey: .altText)
    self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
    self.autoplay = try container.decodeIfPresent(Bool.self, forKey: .autoplay)
    self.autoRepeat = try container.decodeIfPresent(Bool.self, forKey: .autoRepeat)
    self.duration = try container.decodeIfPresent(Double.self, forKey: .duration)
    self.contentPlatform = try container.decodeIfPresent(String.self, forKey: .contentPlatform)
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
    
    func testNestedEncoding() {
            // Arrange
            let mediaContent = MediaContentResponse(
                url: "https://example.com/media",
                mimeType: "image/jpeg",
                altText: "Sample image",
                thumbnail: "https://example.com/thumbnail",
                autoplay: true,
                autoRepeat: false,
                duration: 10.5,
                contentPlatform: "web"
            )
            
            let sample = SubmitReviewRequestBody(
                productId: "12345",
                rating: "5",
                description: "Great product!",
                contents: [mediaContent]
            )
       
        let collectedKeyValues = CodingKeysFinder.collectCodingKeysValue(from: sample)
        print("---------------")
        print(collectedKeyValues)
        print("---------------")
        let expectedKeyValues: [String: String] = [
            "productId": "productId",
            "rating": "rating",
            "description": "description",
            "contents": "contents"
        ]

        XCTAssertEqual(
            collectedKeyValues,
            expectedKeyValues,
            "Collected key-value pairs do not match expected pairs."
        )
            
        }

}
