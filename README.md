
```
                        (__)
                        (DD)
                 /-------\/
               / |     ||_\_/
               *  ||----|
                  ^^    ^
```
# EasyXConnect

EasyConnect is a Swift package that simplifies HTTP requests, including multipart data uploads. It's designed for developers who want an easy-to-use solution for interacting with RESTful APIs, with a focus on simplicity and robust error handling.

## Features

- 🚀 Simple and intuitive API for HTTP requests
- 🔄 Support for GET, POST, PUT, DELETE, and PATCH methods
- 📁 Easy handling of multipart form data for file uploads
- ⚠️ Built-in error handling and response parsing
- 🔧 Customisable headers and query parameters
- ⏳ Asynchronous operations using Swift's modern concurrency features

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/shawon1fb/EasyXConnect.git", from: "1.0.0")
]
```

## Quick Start

1. **Import the package:**

    ```swift
    import EasyXConnect
    ```

2. **Create a client instance:**

    ```swift
    let baseURL = URL(string: "https://httpbin.org")!
    let client = ExHttpConnect(baseURL: baseURL)
    ```

3. **Make a simple GET request:**

    ```swift
    // Define the expected response structure
    struct GetResponse: Decodable {
        let args: [String: String]
        let headers: [String: String]
        let origin: String
        let url: String
    }

    do {
        let response: AppResponse<GetResponse> = try await client.get("get")
        if let payload = response.payload {
            print("Response:", payload)
        }
    } catch {
        print("Error:", error)
    }
    ```

## Usage Examples

### GET Request with Query Parameters

```swift
// Define the DTO for query parameters
struct GetInfoDTO: DTO {
    let foo: String
    let bar: Int

    func toQueryParams() -> [String: String]? {
        return [
            "foo": foo,
            "bar": String(bar)
        ]
    }
}

// Define the expected response structure
struct GetInfoResponse: Decodable {
    let args: [String: String]
    let headers: [String: String]
    let origin: String
    let url: String
}

func fetchInfo() async throws {
    let dto = GetInfoDTO(foo: "hello", bar: 123)
    let response: AppResponse<GetInfoResponse> = try await client.get(
        "get",
        headers: ["Custom-Header": "EasyConnect-Demo"],
        query: dto.toQueryParams()
    )
    if let payload = response.payload {
        print("GET Response:", payload)
    }
}

// Usage
try await fetchInfo()
```

### POST Request with JSON Body

```swift
// Define the DTO for the request body
struct PostDataDTO: DTO {
    let name: String
    let age: Int
}

// Define the expected response structure
struct PostDataResponse: Decodable {
    let json: [String: AnyCodable]
    let data: String
    let url: String
    let headers: [String: String]
}

func postData(name: String, age: Int) async throws {
    let dto = PostDataDTO(name: name, age: age)
    let response: AppResponse<PostDataResponse> = try await client.post(
        "post",
        body: dto.toData(),
        headers: ["Content-Type": "application/json"]
    )
    if let payload = response.payload {
        print("POST Response:", payload)
    }
}

// Usage
try await postData(name: "John Doe", age: 30)
```

**Note:** You'll need to use `AnyCodable` or a similar solution to handle dynamic JSON keys and values.

### Multipart File Upload

```swift
// Define the DTO for the multipart request
struct UploadFileDTO: MultipartDTO {
    var boundary: String = FormData.generateBoundary()
    let filename: String
    let fileURL: URL

    func toJsonMap() -> [String: AnyEncodable]? {
        return [
            "file": AnyEncodable(fileURL)
        ]
    }
}

// Define the expected response structure
struct UploadFileResponse: Decodable {
    let files: [String: String]
    let form: [String: String]
    let headers: [String: String]
    let url: String
}

func uploadFile(filename: String, fileURL: URL) async throws {
    let dto = UploadFileDTO(filename: filename, fileURL: fileURL)
    let response: AppResponse<UploadFileResponse> = try await client.post(
        "post",
        body: dto
    )
    if let payload = response.payload {
        print("File Upload Response:", payload)
    }
}

// Usage
let fileURL = URL(fileURLWithPath: "/path/to/your/file.txt")
try await uploadFile(filename: "example.txt", fileURL: fileURL)
```

### Handling Dynamic JSON Responses

When the API returns a dynamic JSON structure that cannot be represented by a `Decodable` struct, you can handle the response using `AppResponse<Data>` and parse the data manually

```swift
do {
    let response: AppResponse<Data> = try await client.get("get")
    if let payload = response.payload {
        let jsonObject = try JSONSerialization.jsonObject(with: payload, options: [])
        print("Response:", jsonObject)
    }
} catch {
    print("Error:", error)
}

```

This approach allows you to handle any JSON structure without defining specific models. However, you lose the benefits of type safety and may need to handle casting and errors manually.

### Error Handling

EasyConnect uses Swift's built-in error handling. Wrap your API calls in a `do-catch` block to handle potential errors:

```swift
do {
    try await fetchInfo()
} catch let error as HTTPError {
    print("HTTP Error:", error)
} catch {
    print("Unexpected error:", error)
}
```

## Best Practices

1. **Use `Decodable` Structs:** Define `Decodable` structs to match your API responses for type-safe handling.
2. **Use DTOs:** Create Data Transfer Objects (DTOs) to structure your request data.
3. **Error Handling:** Always use `do-catch` blocks to handle errors gracefully.
4. **Async/Await:** Leverage Swift's concurrency features for clean, readable code.
5. **Custom Headers:** Use custom headers when needed for authentication or special requirements.

## Advanced Usage

For more advanced usage, including custom interceptors, caching policies, and complex multipart uploads, please refer to the full API documentation.

## Contributing

We welcome contributions to EasyConnect! If you'd like to contribute:

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes and write tests if applicable
4. Submit a pull request with a clear description of your changes

Please ensure your code adheres to the existing style and passes all tests.

## License

EasyConnect is available under the MIT license. See the LICENSE file for more info.

## Support

If you encounter any issues or have questions, please file an issue on the GitHub repository.

---

Happy coding with EasyXConnect! If you have any questions or need further assistance, don't hesitate to reach out.

---
```
        ^        (___)
        ^        |*-*|
        ^____  _  \o/`-\
              \  / U   |
               \/\   | /
                 |   //
                 |  C/
                 \---/
                 |/\ |
                 || ||
                 || ||
                 || ||
                Cool Cow
```
---
        
