//
//  Order.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation

struct Order: Codable, Identifiable {
    var id: String
    var user: UserInfo?
    var items: [OrderItem]
    var totalAmount: Double
    var status: String
    var shippingAddress: Address
    var createdAt: String
    
    // Computed property for formatted date
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: createdAt) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return createdAt
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user
        case items
        case totalAmount
        case status
        case shippingAddress
        case createdAt
    }
}

// Simplified user info returned in order responses
struct UserInfo: Codable {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case firstName
        case lastName
    }
}

// Response structure for paginated orders
struct OrdersResponse: Codable {
    var orders: [Order]
    var pagination: PaginationInfo
}

struct PaginationInfo: Codable {
    var total: Int
    var page: Int
    var pages: Int
    var limit: Int
} 