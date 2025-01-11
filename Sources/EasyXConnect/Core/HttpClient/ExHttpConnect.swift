//
//  File.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation
import Combine

@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
open class ExHttpConnect : IHttpConnect {
    
    
    public var intercepters: [Intercepter] = []
    
    let baseURL: URL
    let session: URLSession
    
    public init(baseURL: URL, session:URLSession? = nil) {
        self.baseURL = baseURL
        if let session = session{
            self.session =  session
        }else{
            self.session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue())
        }
    }
    
    
    //protocol metods
    public func get< T: Codable>(
        _ url: String,
        headers: [String : String]? = nil,
        query: [String : String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try requestBuilder(url, query: query, body: nil, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "GET"
        return try await sendRequest(url: request)
    }
    
    public func post< T: Codable>(
        _ url: String,
        body: Data?,
        headers: [String : String]? = nil,
        query: [String : String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        
        var request = try requestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "POST"
        return try await sendRequest(url: request)
    }
    
    //Multipart request [post]
    public func post<T>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String : String]? = nil,
        query: [String : String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try multiPartRequestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "POST"
        return try await sendRequest(url: request)
    }
    
    public func put< T: Codable>(
        _ url: String,
        body: Data?,
        headers: [String : String]? = nil,
        query: [String: String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try requestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "PUT"
        return try await sendRequest(url: request)
    }
    
    //Multipart request [put]
    public func put<T>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String : String]?,
        query: [String: String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try multiPartRequestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "PUT"
        return try await sendRequest(url: request)
    }
    
    public func patch< T: Codable>(
        _ url: String,
        body: Data?,
        headers: [String : String]? = nil,
        query: [String: String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try requestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "PATCH"
        return try await sendRequest(url: request)
    }
    
    //Maltipart request [patch]
    public func patch<T>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String : String]?,
        query: [String: String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try multiPartRequestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "PATCH"
        return try await sendRequest(url: request)
    }
    
    public func delete< T: Codable>(
        _ url: String,
        body: Data? = nil,
        headers: [String : String]?,
        query: [String : String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try requestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "DELETE"
        return try await sendRequest(url: request)
    }
    
    func delete<T>(_ url: String, body: MultipartDTO? = nil, headers: [String : String]?, query: [String : String]?, cachePolicy: URLRequest.CachePolicy?) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try multiPartRequestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "DELETE"
        return try await sendRequest(url: request)
    }
    
    
    private func requestBuilder(
        _ path: String,
        query: [String : String]?,
        body: Data?,
        headers: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
        
    )throws -> URLRequest{
        return try RequestBuilder.buildRequest(path, baseURL: baseURL, query: query, body: body, headers: headers, cachePolicy: cachePolicy)
    }
    
    private func multiPartRequestBuilder(
        _ path: String,
        query: [String : String]?,
        body: MultipartDTO?,
        headers: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
        
    )throws -> URLRequest{
        var allHeaders: [String : String] = [:]
        if let headers = headers{
            for (key ,value) in headers{
                allHeaders[key] = value
            }
        }
        
        if let headers = body?.getHeader(){
            for (key ,value) in headers{
                allHeaders[key] = value
            }
        }
        
        return try requestBuilder(path, query: query, body: body?.toData(), headers: allHeaders,cachePolicy: cachePolicy)
    }
    
    
    public func sendRequest<R: Codable>(url: URLRequest  )async throws -> AppResponse<R> {
        
        do{
            
            var req = url
            
            var reqData: Data?
            //MARK: intercepters on request
            for intersepter in intercepters{
                ( req , reqData) = try await intersepter.onRequest(req: req)
            }
            
            // cache true return response
            if let data = reqData {
                //MARK: cache response 298
                return try DataToObjectConverter.dataToObject(data: data, statusCode: 298)
            }
            
            //MARK: make request
            
            let (data, res) = try await performRequest(req)
            
            let response = res as? HTTPURLResponse
            
            var resData:Data = data
            
            //MARK: intercepters on response
            for intersepter in intercepters{
                
                resData = try await intersepter.onResponse(req: url, res: res, data: data)
            }
            return try DataToObjectConverter.dataToObject(data: resData, statusCode: response?.statusCode ?? 299)
        }catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                debugPrint("Data corrupted: \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                debugPrint("Key '\(key)' not found: \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                debugPrint("Type mismatch for type '\(type)'", context.debugDescription)
            case .valueNotFound(let type, let context):
                debugPrint("Value not found for type '\(type)'", context.debugDescription)
            @unknown default:
                debugPrint("Unknown decoding error \(error.errorDescription ?? "" )")
            }
            throw error
        } catch {
            debugPrint("Error during decoding: \(error.localizedDescription)")
            throw error
        }
    }
    
    // This function to make the network request compatible with iOS versions prior to 15.0
    func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *){
            return try await session.data(for: request)
        }else{
            return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
                session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                    else {
                        if let data = data, let response = response {
                            continuation.resume(with: .success((data, response)))
                        }
                    }
                }
            })
        }
    }
}
