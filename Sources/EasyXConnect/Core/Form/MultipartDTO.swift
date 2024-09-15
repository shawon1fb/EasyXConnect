//
//  Untitled.swift
//  EasyXConnect
//
//  Created by shahanul on 15/9/24.
//

import Foundation

public protocol MultipartDTO: DTO {
  //    var boundary: String { get }
  // let boundary:String = FormData.generateBoundary()

  var boundary: String { get set }
}


extension MultipartDTO {

  public func getHeader() -> [String: String] {
    //let boundary:String = generateBoundary()
    //print("boundary header -> ",boundary)
    return [
      "Content-Type": "multipart/form-data; boundary=\(boundary)",
      "Accept": "application/json",
    ]
  }

  public func toData() -> Data? {
    if let map = toJsonMap() {
      //  let boundary:String = generateBoundary()
      // print("boundary -> ",boundary)
      let formData = FormData(map: map, boundary: boundary)
      return formData.toBytes()
    }
    return nil
  }
}
