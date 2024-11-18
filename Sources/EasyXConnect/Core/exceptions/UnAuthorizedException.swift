//
//  UnAuthorizedException.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

public struct UnAuthorizedException: Error {
  public let message: String
  public let stackTrace: String?

  public init(message: String = "wrong credentials", stackTrace: String? = nil) {
    self.message = message
    self.stackTrace = stackTrace
    print(stackTrace ?? "")
  }

  public var localizedDescription: String {
    return message
  }
}

extension UnAuthorizedException: CustomStringConvertible {
  public var description: String {
    return message
  }
}
