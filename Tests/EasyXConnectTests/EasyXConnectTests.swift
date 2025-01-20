import XCTest
@testable import EasyXConnect

final class EasyXConnectTests: XCTestCase {
    func testExample() async throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
       await exampleUsage()
            }
}

// Create the HTTP client
let baseURL = URL(string: "https://httpbin.org")!
let client = ExHttpConnect(baseURL: baseURL)

// MARK: - DTO Definitions

struct HttpBinResponse: Codable {
    let url: String
    let args: [String: String]?
    let headers: [String: String]
    let origin: String
    let masud: String
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
        // POST Request
        let postData = PostData(name: "John Doe", age: 30)
        let postResponse = try await httpBinAPI.postRequest(data: postData)
        print("POST Response:", postResponse)

        
    } catch {
        //print("Error occurred:\n\n", error, "\n\n")
       
    }
}

// Usage examples:
/*
// 1. Setup logging handler
await PrettyErrorPrinter.setLogHandler { message in
    Logger.error(message)  // Your logging system
}

// 2. Using print
await PrettyErrorPrinter.setLogHandler { message in
    print(message)
}

// 3. Getting error string without logging
let errorMessage = PrettyErrorPrinter.prettyError(error)

// 4. Logging with async/await
await PrettyErrorPrinter.prettyPrint(error)

// 5. Using with custom error handling
await PrettyErrorPrinter.setLogHandler { message in
    // Send to analytics
    Analytics.logError(message)
    // Show in UI
    DispatchQueue.main.async {
        showErrorAlert(message)
    }
}
*/
// Usage example:
// try {
//     // Your decoding code
// } catch {
//     PrettyErrorPrinter.prettyPrint(error)
// }

// Usage example:
// try {
//     // Your decoding code
// } catch {
//     PrettyErrorPrinter.prettyPrint(error)
// }

// Usage example:
// try {
//     // Your decoding code
// } catch {
//     PrettyErrorPrinter.prettyPrint(error)
// }
