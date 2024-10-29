//
//  ServerException.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

public class ServerException: Error {
  public let message: String
  public let stackTrace: String?

  public init(message: String = "500 server error", stackTrace: String? = nil) {
    self.message = message
    self.stackTrace = stackTrace
    print(stackTrace ?? "")
  }

  public var localizedDescription: String {
    return message
  }
}

extension ServerException: CustomStringConvertible {
  public var description: String {
    return message
  }
}
