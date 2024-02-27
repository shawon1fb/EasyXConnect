# EasyConnect Documentation

------------------------------------------------------------------------

## Introduction

EasyConnect is a Swift package that simplifies making HTTP requests,
including multipart data uploads, with a focus on ease of use and error
handling.

-   **Version:** ( 0.0.1 )
-   **Author:** ( Shahanul )
-   **License:** ( MIT License )

## Installation

### Swift Package Manager

``` code
dependencies: [
    .package(url: "https://github.com/your-repo/EasyXConnect", from: "1.0.0")
]

    
```


## Usage

### Importing the Package

``` swift
import EasyXConnect
    
```

### Making HTTP Requests

#### Base URL

Establish a base URL for your API or server:

``` swift
let baseURL = URL(string: "https://your-api-endpoint.com")!
    
```

#### Client Initialization

Create an \`ExHttpConnect\` instance with the base URL:

``` swift
let client = ExHttpConnect(baseURL: baseURL)
    
```

#### Making Requests

Use the appropriate method (\`get\`, \`post\`, \`put\`, \`delete\`) to
send requests:

##### Example (POST request with multipart data):

``` swift
func uploadFiles(files: [URL]) async throws {
    let dto = MultipartDTO(files: files)
    let response: AppResponse<String> = try await client.post(
        "uploads",
        body: dto.toData(),
        headers: dto.getHeaders()
    )
    if let payload = response.payload {
        print(payload)
    } else {
        print("No payload received")
    }
}
    
```

### Multipart Data Uploads

Create a \`MultipartDTO\` instance to represent the multipart data:

``` swift
struct MyDTO: MultipartDTO {
    var boundary: String = FormData.generateBoundary()
    let files: [URL]
}
    
```

Provide the \`files\` array containing the URLs of the files to upload.

### Error Handling

Wrap your request code in a \`try-catch\` block to handle potential
errors:

``` swift
do {
    try await uploadFiles(files: [path1, path2, path3])
} catch {
    print("Error uploading files:", error)
}
    
```

### More Exmapls
``` swift
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

struct UploadPhotos: MultipartDTO{
    var boundary: String = FormData.generateBoundary()
    
    let id: Int
    let images: [URL]
    
    func toJsonMap() -> [String: AnyEncodable]? {
        var map: [String: AnyEncodable] = [:]
        map["id"] = AnyEncodable(id)
        map["files"] = AnyEncodable(images)
        return map
    }
}

func uploadImages()async throws{
    let image1 = URL.downloadsDirectory.appending(components: "images.jpeg")
    let image2 = URL.downloadsDirectory.appending(components: "swift-og.png")
    let images: [URL] = [image1, image2]
    let dto = UploadPhotos(id: 10, images: images)
    print(dto.toString())
    
    // Adding the 'dto.getHeaders()' header is mandatory when providing the request body as 'dto.toData()'.
    //  let response: AppResponse<UserResponse> = try await client.post("uploads", body: dto.toData(), headers: dto.getHeader())
    //  or
    let response: AppResponse<UserResponse> = try await client.post("uploads", body: dto)
    if let payload = response.payload{
        print(payload)
    }
}

// example of [get] request with query params
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

// example of [delete] request with query params
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

```

## API Reference

Please refer to the Swift package documentation for detailed information
about each class, method, and property.

## Contribution Guidelines

Outline how users can contribute to the project
