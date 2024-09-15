//
//  EasyMultipart.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//

import Foundation


public struct EasyMultipart: MultipartDTO {
    let dto: DTO
    public var boundary: String = FormData.generateBoundary()

    public init(dto: DTO) {
        self.dto = dto
    }

    public func toJsonMap() -> [String: AnyEncodable]? {
        return dto.toJsonMap()
    }

    // Conforming to the Encodable protocol by implementing the encode(to:) method
    public func encode(to encoder: Encoder) throws {}
}
