//
//  HttpRequestDemo.swift
//  commender
//
//  Created by shahanul on 26/2/24.
//

import Foundation
import EasyXConnect

//create client
let url = URL(string: "http://0.0.0.0:3000")!
let client = ExHttpConnect(baseURL: url)

// MARK: - Create User DTO

// A `struct` representing the Data Transfer Object (DTO) for creating a new user.
//
// This DTO encapsulates the user's name, email, and secret password, which can be
// used when sending data to a server to create a user account.
struct CreateUserDTO: DTO {
    let name: String
    let email: String
    let secretPassword: String
    
    // Converts the `CreateUserDTO` object to a JSON map in the format
    // expected by the server.
    func toJsonMap() -> [String: AnyEncodable]? {
        var map: [String: AnyEncodable] = [:]
        map["name"] = AnyEncodable(name)
        map["email"] = AnyEncodable(email)
        map["passeord"] = AnyEncodable(secretPassword)
        return map
    }
}

struct UserResponse: Codable{
    let  name, email: String
}
func makePostRequest()async throws{
    let dto = CreateUserDTO(name: "EasyX", email: "easyx@easy.com", secretPassword: "super_secret")
    print(dto.toString())
    let response: AppResponse<UserResponse> = try await client.post("create_user", body: dto.toData(), headers: ["Content-Type": "application/json"])
    if let payload = response.payload{
        print(payload)
    }
}

// examle of [get] request with query params
struct UserListDTO: DTO{
    let name: String
}

func makeGetRequest()async throws{
    let dto = UserListDTO(name: "easyx")
    print(dto.toString())
    let response: AppResponse<[UserResponse]> = try await client.get("user_list", headers: ["Content-Type": "application/json"], query: dto.toQueryParams())
    if let payload = response.payload{
        print(payload)
    }
}

// examle of [delete] request with query params
struct DeleteUserDTO: DTO{
    let name: String
}

func makeDeleteRequest()async throws{
    let dto = DeleteUserDTO(name: "easyx")
    print(dto.toString())
    let response: AppResponse<UserResponse> = try await client.delete("user_delete", headers: ["Content-Type": "application/json"], query: dto.toQueryParams())
    if let payload = response.payload{
        print(payload)
    }
}
