//
//  AppResponse.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

struct AppResponse<T> {
    let statusCode: Int
    let payload: T?
    
    var success: Bool {
        return 200...299 ~= statusCode
    }
    
    init(statusCode: Int, payload: T?) {
        self.statusCode = statusCode
        self.payload = payload
    }
}
