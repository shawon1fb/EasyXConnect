//
//  DtoProtocall.swift
//
//
//  Created by shahanul on 24/2/24.
//

import Foundation

protocol DTO: Encodable{
    func toData()-> Data?
}

protocol MultipartDTO:DTO{
//    let boundary:String = ""  //= FormDataHelper.generateBoundary()
}

extension DTO{
    
    func toData()-> Data?{
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            return data
        }catch{
            debugPrint("encodable error is => \(error) ")
        }
        
        return nil
    }
    
    func toString()-> String{
        
        if let data = toData(){
            if let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
        }
        
        return "\(self)"
    }
    
    func toQueryParams() -> [String: String]? {
        if let data = toData(),
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            
            var queryParams: [String: String] = [:]
            
            for (key, value) in jsonObject {
                if let stringValue = value as? String {
                    queryParams[key] = stringValue
                } else if let numberValue = value as? NSNumber {
                    queryParams[key] = "\(numberValue)"
                } else if let boolValue = value as? Bool {
                    queryParams[key] = boolValue ? "true" : "false"
                }
                // You can add additional type conversions as needed
            }
            
            return queryParams.isEmpty ? nil : queryParams
        }
        
        return nil
    }


    
    
}


struct FromData{
    
}

