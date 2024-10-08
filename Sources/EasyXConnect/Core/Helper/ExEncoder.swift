//
//  ExEncoder.swift
//  EasyXConnect
//
//  Created by shahanul on 8/10/24.
//

import Foundation


// Custom Encoder to collect coding keys
class CodingKeyCollectorEncoder: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var collectedKeys: [String] = []

    func container<Key>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        return KeyedEncodingContainer(KeyedContainer(encoder: self))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unkeyed encoding is not supported.")
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Single value encoding is not supported.")
    }

    struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var encoder: CodingKeyCollectorEncoder
        var codingPath: [CodingKey] = []

        init(encoder: CodingKeyCollectorEncoder) {
            self.encoder = encoder
        }

        mutating func encodeNil(forKey key: Key) throws {
            encoder.collectedKeys.append(key.stringValue)
        }

        mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            encoder.collectedKeys.append(key.stringValue)
            // We don't need to encode the value further, so we can return
        }

        mutating func nestedContainer<NestedKey>(
            keyedBy keyType: NestedKey.Type,
            forKey key: Key
        ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
            fatalError("Nested encoding is not supported.")
        }

        mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            fatalError("Nested encoding is not supported.")
        }

        mutating func superEncoder() -> Encoder {
            fatalError("Super encoding is not supported.")
        }

        mutating func superEncoder(forKey key: Key) -> Encoder {
            fatalError("Super encoding is not supported.")
        }
    }
}


final class CodingKeysFinder{
    
    // Function to collect coding keys
    static func collectCodingKeys<T: Encodable>(from value: T) -> [String] {
        let encoder = CodingKeyCollectorEncoder()
        do {
            try value.encode(to: encoder)
        } catch {
            print("Encoding error: \(error)")
        }
        return encoder.collectedKeys
    }

    static  func collectCodingKeysValue<T: Encodable>(from value: T) -> [String: String] {
        let encoder = CodingKeyCollectorEncoder()
        do {
            try value.encode(to: encoder)
        } catch {
            print("Encoding error: \(error)")
        }
        let codingKeys = encoder.collectedKeys

        // Get the property names using reflection
        let mirror = Mirror(reflecting: value)
        let propertyNames = mirror.children.compactMap { $0.label }

        // Map property names to coding keys
        var mapping = [String: String]()
        for (propertyName, codingKey) in zip(propertyNames, codingKeys) {
            mapping[propertyName] = codingKey
        }

        return mapping
    }
}

