//
//  NetworkServiceProtocal.swift
//
//
//  Created by shahanul on 24/2/24.
//
import Foundation

protocol NetworkServiceProtocal{
    func getException(status:Int, message:String?)throws
}

extension NetworkServiceProtocal{
    
    func getException(status:Int, message:String?)throws{
        switch status {
            case 400:
                throw DefaultException(message: message == nil ? "Bad Request" : message!)
            case 401:
                throw UnAuthorizedException(message: message == nil ? "Unauthorized request" : message!)
            case 403:
                throw ForbiddenException(message: message == nil ? "Forbidden request" : message!)
            case 500:
                throw ServerException(message: message == nil ? "server error" : message!)
            default:
                throw DefaultException(message: message == nil ? "something went wrong" : message!)
        }
        
    }
}

