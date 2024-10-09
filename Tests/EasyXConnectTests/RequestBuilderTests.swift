//
//  RequestBuilderTests.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//
import XCTest

// Assuming the RequestBuilder and HTTPError exist in the same module
@testable import EasyXConnect

final class RequestBuilderTests: XCTestCase {

  // Test when all parameters are valid
  func testBuildRequestWithAllParameters() throws {
    let baseURL = URL(string: "https://example.com")!
    let path = "/api/v1/resource"
    let query = ["key": "value"]
    let body = "test body".data(using: .utf8)
    let headers = ["Authorization": "Bearer token"]
    let cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData

    let request = try RequestBuilder.buildRequest(
      path,
      baseURL: baseURL,
      query: query,
      body: body,
      headers: headers,
      cachePolicy: cachePolicy
    )
      if let u = request.url{
          print("----------------------------")
          print(u)
          print("----------------------------")
      }

    XCTAssertEqual(request.url?.absoluteString, "https://example.com/api/v1/resource?key=value")
    XCTAssertEqual(request.httpBody, body)
    XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    XCTAssertEqual(request.cachePolicy, cachePolicy)
  }

  // Test when path is empty (should use baseURL only)
  func testBuildRequestWithEmptyPath() throws {
    let baseURL = URL(string: "https://example.com")!

    let request = try RequestBuilder.buildRequest(
      "",
      baseURL: baseURL,
      query: nil,
      body: nil,
      headers: nil,
      cachePolicy: nil
    )

    XCTAssertEqual(request.url?.absoluteString, "https://example.com")
  }

  // Test when query parameters are provided
  func testBuildRequestWithQueryParams() throws {
    let baseURL = URL(string: "https://example.com")!
    let query = ["key1": "value1", "key2": "value2"]

    let request = try RequestBuilder.buildRequest(
      "/api",
      baseURL: baseURL,
      query: query,
      body: nil,
      headers: nil,
      cachePolicy: nil
    )

    let url = request.url
    let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
    let queryItems = components?.queryItems ?? []

    // Verify the query items match regardless of order
    let expectedQueryItems = [
      URLQueryItem(name: "key1", value: "value1"),
      URLQueryItem(name: "key2", value: "value2"),
    ]

    XCTAssertEqual(Set(queryItems), Set(expectedQueryItems))
  }

  // Test when headers are provided
  func testBuildRequestWithHeaders() throws {
    let baseURL = URL(string: "https://example.com")!
    let headers = ["Content-Type": "application/json", "Authorization": "Bearer token"]

    let request = try RequestBuilder.buildRequest(
      "/api",
      baseURL: baseURL,
      query: nil,
      body: nil,
      headers: headers,
      cachePolicy: nil
    )

    XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
  }

  // Test when body is provided
  func testBuildRequestWithBody() throws {
    let baseURL = URL(string: "https://example.com")!
    let body = "test body".data(using: .utf8)

    let request = try RequestBuilder.buildRequest(
      "/api",
      baseURL: baseURL,
      query: nil,
      body: body,
      headers: nil,
      cachePolicy: nil
    )

    XCTAssertEqual(request.httpBody, body)
  }

  // Test invalid URL scenario (should throw HTTPError.invalidURL)
  func testBuildRequestWithInvalidURL() throws {
    let baseURL = URL(string: "https://example.com")!

    XCTAssertThrowsError(
      try RequestBuilder.buildRequest(
        "::invalid_path::",
        baseURL: baseURL,
        query: nil,
        body: nil,
        headers: nil,
        cachePolicy: nil
      )
    ) { error in
      XCTAssertEqual(error as? HTTPError, HTTPError.invalidURL)
    }
  }

  func testBuildRequest_WithHeaders_ShouldSetHeadersCorrectly() throws {
    let baseURL = URL(string: "https://example.com")!
    let request = try RequestBuilder.buildRequest(
      "", baseURL: baseURL, query: nil, body: nil, headers: ["Authorization": "Bearer token"],
      cachePolicy: nil)

    XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
  }

  func testBuildRequest_WithBody_ShouldSetHttpBody() throws {
    let baseURL = URL(string: "https://example.com")!
    let bodyData = "{\"key\":\"value\"}".data(using: .utf8)!
    let request = try RequestBuilder.buildRequest(
      "", baseURL: baseURL, query: nil, body: bodyData, headers: nil, cachePolicy: nil)

    XCTAssertNotNil(request.httpBody)
    if let httpBody = request.httpBody {
      let bodyString = String(data: httpBody, encoding: .utf8)
      XCTAssertEqual(bodyString, "{\"key\":\"value\"}")
    }
  }

  func testBuildRequest_WithCachePolicy_ShouldSetCorrectCachePolicy() throws {
    let baseURL = URL(string: "https://example.com")!
    let request = try RequestBuilder.buildRequest(
      "", baseURL: baseURL, query: nil, body: nil, headers: nil,
      cachePolicy: .returnCacheDataElseLoad)

    XCTAssertEqual(request.cachePolicy, .returnCacheDataElseLoad)
  }
    
    func testBuildRequest_queryParams_check() throws {
      let baseURL = URL(string: "https://example.com/path?page=1")!
        let query = ["key": "value", "page": "2"]
        print(baseURL)
      let request = try RequestBuilder.buildRequest(
        "", baseURL: baseURL, query: query, body: nil, headers: nil,
        cachePolicy: .returnCacheDataElseLoad)
        if let u = request.url{
            print(u)
        }
       

      XCTAssertEqual(request.cachePolicy, .returnCacheDataElseLoad)
    }
    
    func testBuildRequest_noQueryParams() throws {
        let baseURL = URL(string: "https://example.com/path")!
        let query: [String: String]? = nil
        let request = try RequestBuilder.buildRequest(
            "", baseURL: baseURL, query: query, body: nil, headers: nil,
            cachePolicy: .reloadIgnoringLocalCacheData)
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/path")
        XCTAssertEqual(request.cachePolicy, .reloadIgnoringLocalCacheData)
    }

    func testBuildRequest_overrideQueryParams() throws {
        let baseURL = URL(string: "https://example.com/path?page=1")!
        let query = ["page": "2", "key": "value"]
        let request = try RequestBuilder.buildRequest(
            "", baseURL: baseURL, query: query, body: nil, headers: nil,
            cachePolicy: .useProtocolCachePolicy)
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/path?page=2&key=value")
        XCTAssertEqual(request.cachePolicy, .useProtocolCachePolicy)
    }

    func testBuildRequest_noBaseQueryParams() throws {
        let baseURL = URL(string: "https://example.com/path")!
        let query = ["page": "1"]
        let request = try RequestBuilder.buildRequest(
            "", baseURL: baseURL, query: query, body: nil, headers: nil,
            cachePolicy: .returnCacheDataElseLoad)
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/path?page=1")
        XCTAssertEqual(request.cachePolicy, .returnCacheDataElseLoad)
    }

    func testBuildRequest_withBody() throws {
        let baseURL = URL(string: "https://example.com/path")!
        let query = ["key": "value"]
        let body = Data("test body".utf8)
        let request = try RequestBuilder.buildRequest(
            "", baseURL: baseURL, query: query, body: body, headers: nil,
            cachePolicy: .useProtocolCachePolicy)
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/path?key=value")
        XCTAssertEqual(request.httpBody, body)
        XCTAssertEqual(request.cachePolicy, .useProtocolCachePolicy)
    }

}
