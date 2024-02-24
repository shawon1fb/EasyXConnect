//
//  File.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

public final class RequestBuilder{
    
    public static func buildRequest(
        _ path: String,
        baseURL:URL,
        query: [String : String]?,
        body: Data?,
        headers: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
        
    )throws -> URLRequest{
        
        let url = path.isEmpty ? baseURL: URL(string: path, relativeTo: baseURL)
        
        guard let url = url else{
            throw HTTPError.invalidURL
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        var queryItems:[URLQueryItem] = []
        
        // query params
        if let query = query , !query.isEmpty{
            
            for item in query {
                // print("\(item.key) => \(String(describing: item.value))")
                let v =  URLQueryItem(name: item.key, value: item.value)
                queryItems.append(v)
            }
            
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let apiUrl = urlComponents?.url else {
            throw HTTPError.invalidURL
        }
        print( "url => \(apiUrl.absoluteString)")
        
        var request = URLRequest(url: apiUrl)
        
        // headers
        if let headers = headers, !headers.isEmpty {
            headers.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        //body
        request.httpBody = body
        
        if let cachePolicy = cachePolicy{
            request.cachePolicy = cachePolicy
        }
        
        return request;
    }
}
