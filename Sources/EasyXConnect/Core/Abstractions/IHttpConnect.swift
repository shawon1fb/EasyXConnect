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

protocol IHttpConnect: Sendable {
    
//    var intercepters:[ Intercepter ] { get set }
    
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
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func put<T: Codable>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func patch<T: Codable>(
        _ url: String,
        body: Data?,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func patch<T: Codable>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func delete<T: Codable>(
        _ url: String,
        body: Data?,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
    
    func delete<T: Codable>(
        _ url: String,
        body: MultipartDTO?,
        headers: [String: String]?,
        query: [String: String]?,
        cachePolicy: URLRequest.CachePolicy?
    ) async throws ->  AppResponse<T>
}

public protocol Intercepter: Sendable{
    
    func onRequest(req: URLRequest)async throws ->(URLRequest, Data?)
    
    func onResponse(req: URLRequest , res: URLResponse?, data:Data, modifiedData: Data?, customResponse: URLResponse?) async throws -> (Data, URLResponse?)
    
}
