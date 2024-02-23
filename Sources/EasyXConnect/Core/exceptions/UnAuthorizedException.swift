//
//  UnAuthorizedException.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

class UnAuthorizedException: Error {
    let message: String
    let stackTrace: String?
    
    init(message: String = "wrong credentials", stackTrace: String? = nil) {
        self.message = message
        self.stackTrace = stackTrace
        print(stackTrace ?? "")
    }
    
    var localizedDescription: String {
        return message
    }
}
