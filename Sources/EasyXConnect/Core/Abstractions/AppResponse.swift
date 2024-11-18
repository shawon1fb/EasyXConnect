//
//  AppResponse.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

public struct AppResponse<T: Sendable> : Sendable {
    public    let statusCode: Int
    public let payload: T?
    
    public var success: Bool {
        return 200...299 ~= statusCode
    }
    
    public init(statusCode: Int, payload: T?) {
        self.statusCode = statusCode
        self.payload = payload
    }
}
