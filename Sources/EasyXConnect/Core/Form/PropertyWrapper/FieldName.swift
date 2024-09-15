//
//  FieldName.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//

import Foundation

// Define a generic property wrapper to specify the key


@propertyWrapper
public struct FieldName<T>: Encodable where T: Encodable {
    let key: String
    public var wrappedValue: T

    public init(wrappedValue: T, key: String) {
        self.key = key
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKeys.self)
        try container.encode(wrappedValue, forKey: CustomCodingKeys(stringValue: key))
    }

    private struct CustomCodingKeys: CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
}


protocol AnyFieldName {
    func getKey() -> String
    func getWrappedValue() -> Encodable
}

extension FieldName: AnyFieldName {
    func getKey() -> String {
        return key
    }
    
    func getWrappedValue() -> Encodable {
        return wrappedValue
    }
}
