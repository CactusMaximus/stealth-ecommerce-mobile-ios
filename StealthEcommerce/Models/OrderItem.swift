//
//  OrderItem.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation

struct OrderItem: Codable, Identifiable {
    var id: UUID? = UUID()
    var product: ProductInOrder
    var quantity: Int
    var price: Double
    
    // Computed property for total price
    var total: Double {
        return price * Double(quantity)
    }
    
    // Standard initializer
    init(product: ProductInOrder, quantity: Int, price: Double) {
        self.product = product
        self.quantity = quantity
        self.price = price
    }
    
    private enum CodingKeys: String, CodingKey {
        case product
        case quantity
        case price
    }
    
    // Custom decoding to handle both string product IDs and populated product objects
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quantity = try container.decode(Int.self, forKey: .quantity)
        price = try container.decode(Double.self, forKey: .price)
        
        // Try to decode product as an object first
        do {
            product = try container.decode(ProductInOrder.self, forKey: .product)
        } catch {
            // If that fails, it might be a string ID
            if let productId = try? container.decode(String.self, forKey: .product) {
                // Create a minimal product with just the ID
                product = ProductInOrder(id: productId, name: "Product #\(productId.suffix(6))", price: price, imageUrl: nil)
            } else {
                throw error
            }
        }
    }
}

// Product representation within an order
struct ProductInOrder: Codable, Identifiable {
    var id: String
    var name: String
    var price: Double
    var imageUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case price
        case imageUrl
    }
} 