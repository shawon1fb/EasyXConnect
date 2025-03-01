//
//  PrettyErrorPrinterTests.swift
//  EasyXConnect
//
//  Created by Shahanul Haque on 3/1/25.
//

import XCTest
@testable import EasyXConnect // Replace with your actual module name

let floatToIntJSON = """
{
  "order": {
    "items": [
      {
        "id": 1,
        "price": 29.99
      },
      {
        "id": 2,
        "price": 19.50
      }
    ],
    
    "netShippingFee2": 442.5,
    "netShippingFee": 441.5,
    "totalAmount": 1000,
    "currency": "USD"
  }
}
"""

let missingKeyJSON = """
{
  "order": {
    "items": [
      {
        "id": 1
        // Missing "price" key
      }
    ],
    "netShippingFee": 10.0,
    "totalAmount": 1000,
    "currency": "USD"
  }
}
"""

let nullValueJSON = """
{
  "order": {
    "items": [
      {
        "id": 1,
        "price": null
      }
    ],
    "netShippingFee": 10.0,
    "totalAmount": 1000,
    "currency": "USD"
  }
}
"""

// MARK: - Test Models

struct OrderDetails: Decodable {
    let items: [Item]
    let netShippingFee: Int // This causes the error - should be Double
    let netShippingFee2: Int
    let totalAmount: Int
    let currency: String
    
    struct Item: Decodable {
        let id: Int
        let price: Double
    }
}

struct Order: Decodable {
    let order: OrderDetails
}
func captureError<T: Decodable>(json: String, type: T.Type) -> Error? {
    guard let data = json.data(using: .utf8) else {
        XCTFail("Failed to convert test JSON to Data")
        return nil
    }
    
    do {
        _ = try JSONDecoder().decode(type, from: data)
        XCTFail("Expected decoding to fail but it succeeded")
        return nil
    } catch {
        return error
    }
}

final class PrettyErrorPrinterTests: XCTestCase {
    
   
    
    // MARK: - Tests
    
    func testFloatToIntError() {
        // Arrange
        guard let error = captureError(json: floatToIntJSON, type: Order.self) else { return }
        
        // Act
      // let prettyError = PrettyErrorPrinter.prettyError(error)
        let (prettyError, problematicKeys) = PrettyErrorPrinter.analyzeJSONError(error, jsonString: floatToIntJSON)
        print(error)
        print(prettyError)
        print(problematicKeys)
        
       let keys  = PrettyErrorPrinter.analyzeJSON(floatToIntJSON, problematicValue: "441.5")
        print(" keys -> ")
        print(keys)
      
        //PrettyErrorPrinter.debugJSONAnalysis(jsonString: floatToIntJSON, valueToFind: "441.5")
        // Assert
        XCTAssertTrue(prettyError.contains("not representable in Swift"), "Error message should mention representation issue")
        XCTAssertTrue(prettyError.contains("441.5"), "Error message should contain the problematic value")
        XCTAssertFalse(problematicKeys.isEmpty, "Should find at least one problematic key")
        XCTAssertTrue(problematicKeys.contains { $0.contains("netShippingFee") }, "Should identify netShippingFee as problematic")
    }
    
   
}
