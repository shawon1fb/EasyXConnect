//
//  URLRequestCURLTests.swift
//  EasyXConnect
//
//  Created by Shahanul Haque on 10/17/24.
//

import XCTest

@testable import EasyXConnect

class URLRequestCURLTests: XCTestCase {

  func testBasicGETRequest() {
    let url = URL(string: "https://api.example.com/data")!
    let request = URLRequest(url: url)

    XCTAssertEqual(request.cURL, "curl -X GET \"https://api.example.com/data\"")
  }

  func testPOSTRequestWithHeaders() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer token123", forHTTPHeaderField: "Authorization")

    let curlCommand = request.cURL

    XCTAssertTrue(curlCommand.contains("-X POST"))
    XCTAssertTrue(curlCommand.contains("\"https://api.example.com/data\""))
    XCTAssertTrue(curlCommand.contains("-H \"Content-Type: application/json\""))
    XCTAssertTrue(curlCommand.contains("-H \"Authorization: Bearer token123\""))
  }

  func testRequestWithBody() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = "{\"key\":\"value\"}".data(using: .utf8)

    let expectedCURL = """
      curl -X POST "https://api.example.com/data" -d '{"key":"value"}'
      """

    XCTAssertEqual(request.cURL, expectedCURL)
  }

  func testComplexRequest() {
    let url = URL(string: "https://api.example.com/data?param=value")!
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer token123", forHTTPHeaderField: "Authorization")
    request.httpBody = "{\"update\":\"new value\"}".data(using: .utf8)

    let curlCommand = request.cURL

    XCTAssertTrue(curlCommand.contains("-X PATCH"))
    XCTAssertTrue(curlCommand.contains("\"https://api.example.com/data?param=value\""))
    XCTAssertTrue(curlCommand.contains("-H \"Content-Type: application/json\""))
    XCTAssertTrue(curlCommand.contains("-H \"Authorization: Bearer token123\""))
    XCTAssertTrue(curlCommand.contains("-d '{\"update\":\"new value\"}'"))
  }

  func testNilURL() {
    var request = URLRequest(url: URL(string: "https://api.example.com/data")!)
    request.url = nil

    XCTAssertEqual(request.cURL, "")
  }

  func testNilHTTPMethod() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    request.httpMethod = nil

    XCTAssertEqual(request.cURL, "curl -X GET \"https://api.example.com/data\"")
  }

  func testEmptyBody() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = Data()

    let expectedCURL = "curl -X POST \"https://api.example.com/data\" -d ''"
    XCTAssertEqual(request.cURL, expectedCURL)
  }

  func testBodyWithSpecialCharacters() {
    // Create URL and URLRequest
    guard let url = URL(string: "https://api.example.com/test") else {
      XCTFail("Invalid URL")
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Set headers with special characters
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Use a raw string to include special characters correctly
    let specialCharactersBody = #"""
      {
           "text": "Hello, world! Here's a special character: \\\" and some more: \\\\ and /"
      }
      """#
    request.httpBody = specialCharactersBody.data(using: .utf8)

    // Generate cURL string
    let curlCommand = request.cURL

    let exp = #"""
      "text": "Hello, world! Here'\''s a special character: \\\" and some more: \\\\ and /"
      """#

    // Validate that the generated cURL matches the expected output
    print(curlCommand.contains(exp))
    XCTAssertTrue(curlCommand.contains(exp))
  }

  func testHeadersWithSpecialCharacters() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    request.addValue("application/json; charset=\"utf-8\"", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer tok\"en123", forHTTPHeaderField: "Authorization")

    let curlCommand = request.cURL

    XCTAssertTrue(curlCommand.contains("-H \"Authorization: Bearer tok\\\"en123\""))

    XCTAssertTrue(
      curlCommand.contains("-H \"Content-Type: application/json; charset=\\\"utf-8\\\"\""))
  }

  func testURLWithSpecialCharacters() {
    let url = URL(string: "https://api.example.com/data?param=va%22lue&other='test'")!
    let request = URLRequest(url: url)

    let expectedCURL = "curl -X GET \"https://api.example.com/data?param=va%22lue&other='test'\""
    XCTAssertEqual(request.cURL, expectedCURL)
  }

  func testNonUTF8EncodableBody() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let parameters = "\\xd800"
    let postData = parameters.data(using: .utf8)
//      let postData = Data([0xD8, 0x00])
    request.httpBody = postData
    request.addValue("text/plain", forHTTPHeaderField: "Content-Type")

    let generatedCURL = request.cURL
    let expectedCURL = #"""
      curl -X POST "https://api.example.com/data" -H "Content-Type: text/plain" -d '\xd800'
      """#
    print("---------------generatedCURL---------------------------------------------")
    print(generatedCURL)
    print("---------------expectedCURL---------------------------------------------")
    print(expectedCURL)
    XCTAssertEqual(generatedCURL, expectedCURL)
  }

  func testLargeBodyData() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    let largeString = String(repeating: "a", count: 10000)
    request.httpBody = largeString.data(using: .utf8)

    let expectedCURL = "curl -X GET \"https://api.example.com/data\" -d '\(largeString)'"
    XCTAssertEqual(request.cURL, expectedCURL)
  }

  func testBinaryBodyData() {
    let url = URL(string: "https://api.example.com/upload")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let binaryData = Data([0x00, 0xFF, 0xAA, 0x55])
    request.httpBody = binaryData

    let curlCommand = request.cURL
    print("---------------generatedCURL---------------------------------------------")
    print(curlCommand)

    // Correct expected cURL command
    let expectedCURL = #"""
      curl -X POST "https://api.example.com/upload" --data-binary $'\x00\xFF\xAA\x55'
      """#

    XCTAssertEqual(curlCommand, expectedCURL)
  }

  func testAllHTTPHeaderFieldsNil() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = nil

    let expectedCURL = "curl -X GET \"https://api.example.com/data\""
    XCTAssertEqual(request.cURL, expectedCURL)
  }

  func testMultipleHeadersWithSameField() {
    let url = URL(string: "https://api.example.com/data")!
    var request = URLRequest(url: url)
    request.addValue("value1", forHTTPHeaderField: "Custom-Header")
    request.addValue("value2", forHTTPHeaderField: "Custom-Header2")

    let curlCommand = request.cURL

    print(curlCommand)
    // Note: URLRequest only keeps the last value for a given header field
    XCTAssertTrue(curlCommand.contains("-H \"Custom-Header2: value2\""))
    XCTAssertTrue(curlCommand.contains("-H \"Custom-Header: value1\""))
  }

}
