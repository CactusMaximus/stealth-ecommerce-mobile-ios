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

// New struct for order creation response
struct OrderCreationResponse: Codable {
    var id: String?
    var orderId: String?
    var message: String?
    var order: Order?
    
    // Flexible init to handle different response formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode id or orderId
        if let id = try? container.decodeIfPresent(String.self, forKey: .idField) {
            self.id = id
        } else if let orderId = try? container.decodeIfPresent(String.self, forKey: .orderId) {
            self.orderId = orderId
        }
        
        // Try to decode message
        self.message = try? container.decodeIfPresent(String.self, forKey: .message)
        
        // Try to decode order object
        self.order = try? container.decodeIfPresent(Order.self, forKey: .order)
    }
    
    // Custom encoder to match the decoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = self.id {
            try container.encode(id, forKey: .idField)
        }
        
        if let orderId = self.orderId {
            try container.encode(orderId, forKey: .orderId)
        }
        
        if let message = self.message {
            try container.encode(message, forKey: .message)
        }
        
        if let order = self.order {
            try container.encode(order, forKey: .order)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case idField = "_id"
        case orderId
        case message
        case order
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
    
    // Custom decoder to handle different response formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode orders directly, or from a nested "orders" field
        if let directOrders = try? container.decode([Order].self, forKey: .orders) {
            self.orders = directOrders
        } else if let singleOrder = try? container.decode(Order.self, forKey: .singleOrder) {
            // Handle case where server returns a single order object
            self.orders = [singleOrder]
        } else {
            // If neither works, try to decode from the top level as an array
            do {
                let topLevelContainer = try decoder.singleValueContainer()
                if let orderArray = try? topLevelContainer.decode([Order].self) {
                    self.orders = orderArray
                } else {
                    // If all attempts fail, return empty array
                    self.orders = []
                }
            } catch {
                self.orders = []
            }
        }
        
        // Try to decode pagination info, or create default
        if let pagination = try? container.decode(PaginationInfo.self, forKey: .pagination) {
            self.pagination = pagination
        } else {
            // Create default pagination info
            self.pagination = PaginationInfo(
                total: self.orders.count,
                page: 1,
                pages: 1,
                limit: self.orders.count
            )
        }
    }
    
    // Custom encoder to match the decoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(orders, forKey: .orders)
        try container.encode(pagination, forKey: .pagination)
    }
    
    private enum CodingKeys: String, CodingKey {
        case orders
        case singleOrder = "order"
        case pagination
    }
}

struct PaginationInfo: Codable {
    var total: Int
    var page: Int
    var pages: Int
    var limit: Int
    
    // Default initializer for when pagination info isn't provided
    init(total: Int, page: Int, pages: Int, limit: Int) {
        self.total = total
        self.page = page
        self.pages = pages
        self.limit = limit
    }
} 