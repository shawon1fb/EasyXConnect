//
//  AnyEncodable.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//

import Foundation

public struct AnyEncodable: Encodable {
    public let value: Any

    private let encodeClosure: (Encoder) throws -> Void

    public init<T: Encodable>(_ value: T) {
        self.value = value
        self.encodeClosure = { encoder in
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
