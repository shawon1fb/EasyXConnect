//
//  DefaultException.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

public struct DefaultException: Error {
  public let message: String
  public let stackTrace: String?

  public init(
    message: String = "Error loading data, check your internet!", stackTrace: String? = nil
  ) {
    self.message = message
    self.stackTrace = stackTrace
    print(stackTrace ?? "")
  }
}

extension DefaultException: CustomStringConvertible {
  public var description: String {
    return message
  }
}
