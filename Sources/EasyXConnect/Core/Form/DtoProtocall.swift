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

        for case let (label?, value) in mirror.children {
            // Check if the value is Optional
            let mirrorValue = Mirror(reflecting: value)
            if mirrorValue.displayStyle == .optional {
                if mirrorValue.children.isEmpty {
                    // Skip nil optionals
                    continue
                }
            }

            // Handle encodable values
            if let encodableValue = value as? Encodable {
                map[label] = AnyEncodable(encodableValue)
            } else if let guardValue = value as? CustomStringConvertible {
                // Convert non-encodable values using CustomStringConvertible
                map[label] = AnyEncodable(guardValue.description)
            }
        }

        return map.isEmpty ? nil : map
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

}
