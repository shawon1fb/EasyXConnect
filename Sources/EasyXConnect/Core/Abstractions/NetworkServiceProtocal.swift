//
//  NetworkServiceProtocal.swift
//
//
//  Created by shahanul on 24/2/24.
//
import Foundation
public protocol NetworkServiceProtocal {
    func getException(status: Int, message: String?) throws
}

extension NetworkServiceProtocal {
    
    public func getException(status: Int, message: String?) throws {
        switch status {
            case 400:
                throw DefaultException(message: message ?? "The server could not process the request due to invalid input.")
            case 401:
                throw UnAuthorizedException(message: message ?? "Access denied. Please check your credentials and try again.")
            case 403:
                throw ForbiddenException(message: message ?? "You do not have the necessary permissions to access this resource.")
            case 500:
                throw ServerException(message: message ?? "An unexpected error occurred on the server. Please try again later.")
            default:
                throw DefaultException(message: message ?? "An unexpected error occurred. Please contact support if the problem persists.")
        }
    }
}
