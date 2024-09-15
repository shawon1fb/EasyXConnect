//
//  DataToObjectConverter.swift
//
//
//  Created by shahanul on 25/2/24.
//

import Foundation

public class DataToObjectConverter {

  static public func dataToObject<R: Codable>(data: Data, statusCode: Int) throws -> AppResponse<R>
  {
    if R.self == Data.self {
      return AppResponse(statusCode: statusCode, payload: data as? R)
    }

    if R.self == String.self {
      return AppResponse(statusCode: statusCode, payload: String(data: data, encoding: .utf8) as? R)
    }

    let payload = try JSONDecoder().decode(R.self, from: data)

    return AppResponse(statusCode: statusCode, payload: payload)
  }

}
