//
//  File.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

public final class RequestBuilder {

  public static func buildRequest(
    _ path: String,
    baseURL: URL,
    query: [String: String]?,
    body: Data?,
    headers: [String: String]?,
    cachePolicy: URLRequest.CachePolicy?

  ) throws -> URLRequest {

    let url = path.isEmpty ? baseURL : URL(string: path, relativeTo: baseURL)
    guard let url = url, url.scheme?.isEmpty == false else {
      throw HTTPError.invalidURL
    }

    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)

    // Only add query items if query parameters exist
    if let query = query, !query.isEmpty {
      var queryItems: [URLQueryItem] = []
        
        if let existingQueryItems = urlComponents?.queryItems {
          queryItems.append(contentsOf: existingQueryItems)
        }
        
        // Then, add or update query items from the new query
           for item in query {
               let newItem = URLQueryItem(name: item.key, value: item.value)
               
               if let index = queryItems.firstIndex(where: { $0.name == item.key }) {
                   // If the item already exists, replace it
                   queryItems[index] = newItem
               } else {
                   // If it doesn't exist, append it
                   queryItems.append(newItem)
               }
           }
     
      urlComponents?.queryItems = queryItems
    } else {
      // Explicitly set queryItems to nil if there are no query parameters
      //      urlComponents?.queryItems = nil
    }

    guard let apiUrl = urlComponents?.url else {
      throw HTTPError.invalidURL
    }

    var request = URLRequest(url: apiUrl)

    // headers
    if let headers = headers, !headers.isEmpty {
      headers.forEach { key, value in
        request.setValue(value, forHTTPHeaderField: key)
      }
    }

    //body
    request.httpBody = body

    if let cachePolicy = cachePolicy {
      request.cachePolicy = cachePolicy
    }

    return request
  }
}
