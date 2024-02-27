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
swift package add EasyConnect
    
```


## Usage

### Importing the Package

``` swift
import EasyConnect
    
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

## API Reference

Please refer to the Swift package documentation for detailed information
about each class, method, and property.

## Contribution Guidelines

Outline how users can contribute to the project
