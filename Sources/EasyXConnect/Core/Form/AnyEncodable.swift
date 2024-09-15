//
//  AnyEncodable.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//


import Foundation

// Define the AnyEncodable type
public struct AnyEncodable: Encodable {

  public let value: Encodable

  public init(_ value: Encodable) {
    self.value = value
  }

  public func encode(to encoder: Encoder) throws {
    try value.encode(to: encoder)
  }
}
