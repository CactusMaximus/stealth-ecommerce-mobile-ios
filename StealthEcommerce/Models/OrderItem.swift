//
//  OrderItem.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation

struct OrderItem: Codable, Identifiable {
    var id: String { product.id }
    var product: ProductInOrder
    var quantity: Int
    
    // Computed property for the total price of this item
    var total: Double {
        return product.price * Double(quantity)
    }
}

// A simplified product model for orders
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