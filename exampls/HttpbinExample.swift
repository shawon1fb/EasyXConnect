//
//  HttpbinExample.swift
//  EasyXConnect
//
//  Created by shahanul on 30/9/24.
//
//

import Foundation
import EasyXConnect

// Create the HTTP client
let baseURL = URL(string: "https://httpbin.org")!
let client = ExHttpConnect(baseURL: baseURL)

// MARK: - DTO Definitions

struct HttpBinResponse: Codable {
    let url: String
    let args: [String: String]?
    let headers: [String: String]
    let origin: String
    let data: String?
    let files: [String: String]?
    let form: [String: String]?
    let json: [String: String]?
}

struct PostData: DTO {
    let name: String
    let age: Int
}

struct QueryParams: DTO {
    let param1: String
    let param2: Int
    
    //MARK: For json key rename [optional]
    func toJsonMap() -> [String: AnyEncodable]? {
        return [
            "param1_renamed": AnyEncodable(param1),
            "param2_renamed": AnyEncodable(param2)
        ]
    }
}

struct FileUpload: MultipartDTO {
    var boundary: String = FormData.generateBoundary()
    let fileURL: URL
    
    //MARK: For json key rename [optional]
    func toJsonMap() -> [String: AnyEncodable]? {
        return [
            "file": AnyEncodable(fileURL)
        ]
    }
}

// MARK: - API Calls

class HttpBinAPI {
    let client: ExHttpConnect
    
    init(client: ExHttpConnect) {
        self.client = client
    }
    
    // GET Request
    func getRequest(params: QueryParams) async throws -> HttpBinResponse {
        let response: AppResponse<HttpBinResponse> = try await client.get(
            "get",
            headers: ["Custom-Header": "TestValue"],
            query: params.toQueryParams(),
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        
        if response.success, let data = response.payload {
            return data
        } else {
            throw HTTPError.invalidResponse
        }
    }
    
    // POST Request
    func postRequest(data: PostData) async throws -> HttpBinResponse {
        let response: AppResponse<HttpBinResponse> = try await client.post(
            "post",
            body: data.toData(),
            headers: ["Content-Type": "application/json"]
        )
        
        if response.success, let data = response.payload {
            return data
        } else {
            throw HTTPError.invalidResponse
        }
    }
    
    // PUT Request
    func putRequest(data: PostData) async throws -> HttpBinResponse {
        let response: AppResponse<HttpBinResponse> = try await client.put(
            "put",
            body: data.toData(),
            headers: ["Content-Type": "application/json"]
        )
        
        if response.success, let data = response.payload {
            return data
        } else {
            throw HTTPError.invalidResponse
        }
    }
    
    // DELETE Request
    func deleteRequest() async throws -> HttpBinResponse {
        let response: AppResponse<HttpBinResponse> = try await client.delete(
            "delete",
            headers: ["Content-Type": "application/json"]
        )
        
        if response.success, let data = response.payload {
            return data
        } else {
            throw HTTPError.invalidResponse
        }
    }
    
    // PATCH Request
    func patchRequest(data: PostData) async throws -> HttpBinResponse {
        let response: AppResponse<HttpBinResponse> = try await client.patch(
            "patch",
            body: data.toData(),
            headers: ["Content-Type": "application/json"]
        )
        
        if response.success, let data = response.payload {
            return data
        } else {
            throw HTTPError.invalidResponse
        }
    }
    
    // Multipart POST Request
    func uploadFile(fileURL: URL) async throws -> HttpBinResponse {
        let dto = FileUpload(fileURL: fileURL)
        let response: AppResponse<HttpBinResponse> = try await client.post(
            "post",
            body: dto
        )
        
        if response.success, let data = response.payload {
            return data
        } else {
            throw HTTPError.invalidResponse
        }
    }
}

// MARK: - Usage Examples

func exampleUsage() async {
    let httpBinAPI = HttpBinAPI(client: client)
    
    do {
        // GET Request
        let getParams = QueryParams(param1: "hello", param2: 123)
        let getResponse = try await httpBinAPI.getRequest(params: getParams)
        print("GET Response:", getResponse)
        
        // POST Request
        let postData = PostData(name: "John Doe", age: 30)
        let postResponse = try await httpBinAPI.postRequest(data: postData)
        print("POST Response:", postResponse)
        
        // PUT Request
        let putData = PostData(name: "Jane Doe", age: 28)
        let putResponse = try await httpBinAPI.putRequest(data: putData)
        print("PUT Response:", putResponse)
        
        // DELETE Request
        let deleteResponse = try await httpBinAPI.deleteRequest()
        print("DELETE Response:", deleteResponse)
        
        // PATCH Request
        let patchData = PostData(name: "John Updated", age: 31)
        let patchResponse = try await httpBinAPI.patchRequest(data: patchData)
        print("PATCH Response:", patchResponse)
        
        // Multipart POST Request
        let fileURL = URL(fileURLWithPath: "/path/to/test_file.txt")
        let fileUploadResponse = try await httpBinAPI.uploadFile(fileURL: fileURL)
        print("File Upload Response:", fileUploadResponse)
        
    } catch {
        print("Error occurred:", error)
    }
}

// Run the example
//Task {
//    await exampleUsage()
//}

