//
//  CartViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation
import SwiftUI

class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var shippingAddress = Address()
    
    // Computed properties for cart summary
    var subtotal: Double {
        items.reduce(0) { $0 + $1.total }
    }
    
    let shippingCost: Double = 5.0
    
    var total: Double {
        subtotal + shippingCost
    }
    
    // Add item to cart
    func addToCart(product: Product, quantity: Int) {
        // Check if product already exists in cart
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            // Update quantity if product already exists
            items[index].quantity += quantity
        } else {
            // Add new item if product doesn't exist in cart
            let newItem = CartItem(product: product, quantity: quantity)
            items.append(newItem)
        }
        
        // Notify user that item was added
        NotificationCenter.default.post(name: NSNotification.Name("ItemAddedToCart"), object: nil)
    }
    
    // Remove item from cart
    func removeItem(at indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
    
    // Update quantity of an item
    func updateQuantity(for itemID: UUID, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == itemID }) {
            items[index].quantity = max(1, quantity) // Ensure quantity is at least 1
        }
    }
    
    // Clear cart
    func clearCart() {
        items.removeAll()
    }
    
    // Process checkout - this will be called by OrderViewModel
    func prepareForCheckout() -> [CartItem] {
        return items
    }
    
    // Update shipping address
    func updateShippingAddress(street: String, city: String, state: String, zipCode: String) {
        shippingAddress = Address(street: street, city: city, state: state, zipCode: zipCode)
    }
} 