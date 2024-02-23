//
//  NotFoundException.swift
//  
//
//  Created by shahanul on 24/2/24.
//

import Foundation

class NotFoundException: Error {
    let message: String
    let stackTrace: String?
    
    init(message: String = "data not found", stackTrace: String? = nil) {
        self.message = message
        self.stackTrace = stackTrace
        print(stackTrace ?? "")
    }
    
    var localizedDescription: String {
        return message
    }
}

