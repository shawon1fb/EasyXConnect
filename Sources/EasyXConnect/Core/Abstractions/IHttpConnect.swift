//
//  IHttpConnect.swift
//
//
//  Created by shahanul on 24/2/24.
//
import Foundation

public enum HTTPError: Error {
    case requestFailed
    case invalidResponse
    case dataConversionFailed
    case invalidURL
}

protocol IHttpConnect {
    
    var intersepters:[ Intercepter ] { get set }
    
    func get<T: Codable>(
        _ url: String,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func post<T: Codable>(
        _ url: String,
        body: Data?,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func post<T: Codable>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func put<T: Codable>(
        _ url: String,
        body: Data?,
        headers: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func put<T: Codable>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func patch<T: Codable>(
        _ url: String,
        body: Data?,
        headers: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    func patch<T: Codable>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func delete<T: Codable>(
        _ url: String,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
}

public protocol Intercepter{
    
    func onRequest(req: URLRequest)->(URLRequest, Data?)
    
    func onResponse(req: URLRequest , res: URLResponse?, data:Data) -> Data
    
}


public class DefaultHttpConnect : IHttpConnect {
   
 
    
    
    
    
    public var intersepters: [Intercepter] = []
    
    
    let baseURL: URL
    let session: URLSession
    
    public init(baseURL: URL, session:URLSession? = nil) {
        self.baseURL = baseURL
        if let session = session{
            self.session =  session
        }else{
            self.session = URLSession(configuration: .default)
        }
    }
    
    
    //protocall metods
    public func get< T: Codable>(_ url: String, headers: [String : String]? = nil, query: [String : String]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try requestBuilder(url, query: query, body: nil, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "GET"
        return try await sendRequest(url: request)
    }
    
    public func post< T: Codable>(_ url: String, body: Data?, headers: [String : String]? = nil, query: [String : String]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        
        var request = try requestBuilder(url, query: query, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "POST"
        return try await sendRequest(url: request)
    }
    
    //Maltipart request [post]
    func post<T>(_ url: String, body: MultipartDTO?, headers: [String : String]?, query: [String : String]?, cachePolicy: URLRequest.CachePolicy?) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try multiPartRequestBuilder(url, query: nil, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "POST"
        return try await sendRequest(url: request)
    }
    
    public func put< T: Codable>(_ url: String, body: Data?, headers: [String : String]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try requestBuilder(url, query: nil, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "PUT"
        return try await sendRequest(url: request)
    }
    
    //Maltipart request [put]
    func put<T>(_ url: String, body: MultipartDTO?, headers: [String : String]?, cachePolicy: URLRequest.CachePolicy?) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try multiPartRequestBuilder(url, query: nil, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "PUT"
        return try await sendRequest(url: request)
    }
    
    public func patch< T: Codable>(_ url: String, body: Data?, headers: [String : String]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try requestBuilder(url, query: nil, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "PATCH"
        return try await sendRequest(url: request)
    }
    
    //Maltipart request [patch]
    func patch<T>(_ url: String, body: MultipartDTO?, headers: [String : String]?, cachePolicy: URLRequest.CachePolicy?) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try multiPartRequestBuilder(url, query: nil, body: body, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "PATCH"
        return try await sendRequest(url: request)
    }
    
    public func delete< T: Codable>(_ url: String, headers: [String : String]?, query: [String : String]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> AppResponse<T> where T : Decodable, T : Encodable {
        var request = try requestBuilder(url, query: query, body: nil, headers: headers,cachePolicy: cachePolicy)
        request.httpMethod = "DELETE"
        return try await sendRequest(url: request)
    }
    
    
    
    private func requestBuilder( _ path: String,
                                 query: [String : String]?,
                                 body: Data?,
                                 headers: [String: String]?,
                                 cachePolicy: URLRequest.CachePolicy?
                                 
    )throws -> URLRequest{
        return try RequestBuilder.buildRequest(path, baseURL: baseURL, query: query, body: body, headers: headers, cachePolicy: cachePolicy)
    }
    
    private func multiPartRequestBuilder( _ path: String,
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
    
    
    private func sendRequest<R: Codable>(url: URLRequest  )async throws -> AppResponse<R> {
        
        do{
            
            var req = url
            
            var reqData: Data?
            //MARK: intercepters on request
            for intersepter in intersepters{
                ( req , reqData) = intersepter.onRequest(req: req)
            }
            
            if let data = reqData {
                /// cache true return response
                let responseData = try JSONDecoder().decode(R.self, from: data)
                
                //MARK: cahce response 298
                return AppResponse(statusCode: 298 , payload: responseData);
            }
            
            //MARK: make request
            let (data, res) = try await session.data(for: req)
            
            let response = res as? HTTPURLResponse
            
            var resData:Data = data
            
            //MARK: intercepters on response
            for intersepter in intersepters{
                
                resData = intersepter.onResponse(req: url, res: res, data: data)
            }
            
            if R.self == Data.self{
                return AppResponse(statusCode:  response?.statusCode ?? 299 , payload: resData as? R);
            }
            
            if R.self == String.self{
                return AppResponse(statusCode:  response?.statusCode ?? 299 , payload: String(data: resData, encoding: .utf8) as? R);
            }
            
            let responseData = try JSONDecoder().decode(R.self, from: resData)
            
            return AppResponse(statusCode:  response?.statusCode ?? 299 , payload: responseData);
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
}


