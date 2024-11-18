//
//  NotFoundException.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

public struct NotFoundException: Error {
  public let message: String
  public let stackTrace: String?

  public init(message: String = "data not found", stackTrace: String? = nil) {
    self.message = message
    self.stackTrace = stackTrace
    print(stackTrace ?? "")
  }

  public var localizedDescription: String {
    return message
  }
}

extension NotFoundException: CustomStringConvertible {
  public var description: String {
    return message
  }
}
