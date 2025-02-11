//
//  DTOProtocoll.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

public protocol DTO: Encodable {
  func toData() -> Data?
  func toJsonMap() -> [String: AnyEncodable]?
  func toQueryParams() -> [String: String]?
}

extension DTO {
  public func toJsonMap() -> [String: AnyEncodable]? {
    let mirror = Mirror(reflecting: self)
    var map = [String: AnyEncodable]()

    let codingKeys = CodingKeysFinder.collectCodingKeysValue(from: self)

    for case let (label?, value) in mirror.children {
      let mirrorValue = Mirror(reflecting: value)
      if mirrorValue.displayStyle == .optional && mirrorValue.children.isEmpty {
        continue  // Skip nil optionals
      }

      let key = codingKeys[label] ?? label

      // Handle special types
      if let urlValue = value as? URL {
        map[key] = AnyEncodable(urlValue.absoluteString)
      } else if let enumValue = value as? (any RawRepresentable),
        let rawValue = enumValue.rawValue as? Encodable
      {
        map[key] = AnyEncodable(rawValue)
      } else if let encodableValue = value as? Encodable {
        map[key] = AnyEncodable(encodableValue)
      } else {
        map[key] = AnyEncodable(String(describing: value))
      }
    }

    return map.isEmpty ? nil : map
  }

  private func isNil(_ value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    return mirror.displayStyle == .optional && mirror.children.isEmpty
  }

  public func toData() -> Data? {
    guard let map = toJsonMap() else { return nil }

    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(map)
      return data
    } catch {
      debugPrint("Encoding error: \(error)")
      return nil
    }
  }

  public func toString() -> String {

    if let data = toData() {
      if let jsonString = String(data: data, encoding: .utf8) {
        return jsonString
      }
    }

    return "\(self)"
  }

  public func toQueryParams() -> [String: String]? {
    if let jsonObject = toJsonMap() {

      var queryParams: [String: String] = [:]
      for (key, value) in jsonObject {
        if let stringValue = value.value as? String {
          queryParams[key] = stringValue
        } else if let boolValue = value.value as? Bool {
          queryParams[key] = boolValue ? "true" : "false"
        } else if let numberValue = value.value as? NSNumber {
          queryParams[key] = "\(numberValue)"
        } else if let value = value.value as? DTO {
          queryParams[key] = value.toString()
        } else {
          queryParams[key] = "\(value.value)"
        }
      }
      return queryParams.isEmpty ? nil : queryParams
    }

    return nil
  }

  public func toDataWithNotNull() -> Data {
    let map: [String: AnyEncodable] = toJsonMap() ?? [:]
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(map)
      return data
    } catch {
      debugPrint("Encoding error: \(error)")
      return "{}".data(using: .utf8) ?? Data()
    }
  }
}
