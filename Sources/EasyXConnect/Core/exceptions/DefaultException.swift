//
//  DefaultException.swift
//  
//
//  Created by shahanul on 24/2/24.
//

import Foundation

struct DefaultException: Error {
    let message: String
    let stackTrace: String?
    
    init(message: String = "Error loading data, check your internet!", stackTrace: String? = nil) {
        self.message = message
        self.stackTrace = stackTrace
        print(stackTrace ?? "")
    }
}

extension DefaultException: CustomStringConvertible {
    var description: String {
        return message
    }
}

