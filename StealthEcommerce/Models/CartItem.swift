//
//  CartItem.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
    
    // Computed property for the total price of this item
    var total: Double {
        return product.price * Double(quantity)
    }
} 