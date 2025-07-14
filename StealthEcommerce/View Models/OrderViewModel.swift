//
//  OrderViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation
import SwiftUI

class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var currentPage = 1
    @Published var hasMorePages = false
    @Published var useMockData = false
    
    private let networkService = NetworkService.shared
    
    // Define EmptyRequest struct for GET requests
    struct EmptyRequest: Codable {}
    
    // Load mock orders for demo purposes
    func loadMockOrders() {
        isLoading = true
        
        // Simulate network delay
        let workItem = DispatchWorkItem {
            self.orders = [
                Order (
                    id: "ORD123456789",
                    user: UserInfo(id: "user123", email: "demo@example.com", firstName: "John", lastName: "Doe"),
                    items: [
                        OrderItem(product: ProductInOrder(id: "p1", name: "Avocado", price: 2.99, imageUrl: ""), quantity: 3),
                        OrderItem(product: ProductInOrder(id: "p2", name: "Banana", price: 1.99, imageUrl: ""), quantity: 2)
                    ],
                    totalAmount: 12.95,
                    status: "delivered",
                    shippingAddress: Address(street: "123 Main St", city: "San Francisco", state: "CA", zipCode: "94105"),
                    createdAt: "2025-07-01T12:00:00.000Z"
                ),
                Order(
                    id: "ORD987654321",
                    user: UserInfo(id: "user123", email: "demo@example.com", firstName: "John", lastName: "Doe"),
                    items: [
                        OrderItem(product: ProductInOrder(id: "p3", name: "Apple", price: 1.49, imageUrl: ""), quantity: 5)
                    ],
                    totalAmount: 7.45,
                    status: "processing",
                    shippingAddress: Address(street: "456 Market St", city: "San Francisco", state: "CA", zipCode: "94105"),
                    createdAt: "2025-07-05T12:00:00.000Z"
                ),
                Order(
                    id: "ORD456789123",
                    user: UserInfo(id: "user123", email: "demo@example.com", firstName: "John", lastName: "Doe"),
                    items: [
                        OrderItem(product: ProductInOrder(id: "p4", name: "Orange", price: 0.99, imageUrl: ""), quantity: 10)
                    ],
                    totalAmount: 9.90,
                    status: "pending",
                    shippingAddress: Address(street: "789 Mission St", city: "San Francisco", state: "CA", zipCode: "94105"),
                    createdAt: "2025-07-10T12:00:00.000Z"
                )
            ]
            
            self.isLoading = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    // Fetch order history for a user
    func fetchOrderHistory(userId: String, page: Int = 1, completion: @escaping () -> Void = {}) {
        isLoading = true
        errorMessage = nil
        
        // First check if the server is reachable
        APIConstants.checkServerConnection { isConnected, errorMsg in
            if !isConnected {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = errorMsg ?? "Unable to connect to the server. Please check your internet connection and try again."
                    print("❌ Server connection check failed: \(errorMsg ?? "Unknown error")")
                    completion()
                }
                return
            }
            
            let url = "\(APIConstants.Endpoints.orders)/user/\(userId)?page=\(page)"
            
            // Use a custom URLSession task to first check the response content type
            guard let requestUrl = URL(string: url) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Invalid URL"
                    completion()
                }
                return
            }
            
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            print("🔍 Fetching order history from: \(url)")
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    // Handle network error
                    if let error = error {
                        self?.errorMessage = "Network error: \(error.localizedDescription)"
                        print("❌ Order history fetch error: \(error)")
                        completion()
                        return
                    }
                    
                    // Check response type
                    if let httpResponse = response as? HTTPURLResponse {
                        let statusCode = httpResponse.statusCode
                        print("📡 Response Status Code: \(statusCode)")
                        
                        // Handle 404 specifically with a user-friendly message
                        if statusCode == 404 {
                            self?.errorMessage = "No order history found. Please place an order first."
                            print("❌ 404 Not Found: No orders found for this user")
                            completion()
                            return
                        }
                        
                        // Check content type
                        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
                            print("📄 Content Type: \(contentType)")
                            
                            // If we're getting HTML instead of JSON
                            if contentType.contains("text/html") {
                                if statusCode == 404 {
                                    self?.errorMessage = "No order history found. Please place an order first."
                                } else {
                                    self?.errorMessage = "The server returned an unexpected response. Please try again later."
                                }
                                print("❌ Server returned HTML instead of JSON")
                                
                                // Print the HTML for debugging
                                if let data = data, let htmlString = String(data: data, encoding: .utf8) {
                                    print("📄 HTML Response: \(htmlString.prefix(500))...")
                                }
                                
                                completion()
                                return
                            }
                        }
                        
                        // Handle error status codes
                        if statusCode >= 400 {
                            var errorMsg = "Server error: \(statusCode)"
                            
                            // Try to extract error message from response
                            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let message = json["error"] as? String {
                                errorMsg = message
                            }
                            
                            // Provide more user-friendly messages for common errors
                            switch statusCode {
                            case 401:
                                errorMsg = "Your session has expired. Please log in again."
                            case 403:
                                errorMsg = "You don't have permission to view these orders."
                            case 500, 502, 503, 504:
                                errorMsg = "The server is currently unavailable. Please try again later."
                            default:
                                break
                            }
                            
                            self?.errorMessage = errorMsg
                            print("❌ Server error: \(errorMsg)")
                            completion()
                            return
                        }
                    }
                    
                    // Ensure we have data
                    guard let data = data else {
                        self?.errorMessage = "No data received"
                        print("❌ No data received")
                        completion()
                        return
                    }
                    
                    // Print raw data for debugging
                    print("📊 Received \(data.count) bytes")
                    if data.count < 1000 {
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("📄 Raw JSON: \(jsonString)")
                        }
                    }
                    
                    // Handle empty response (which might be valid in some cases)
                    if data.count == 0 || (data.count == 2 && String(data: data, encoding: .utf8) == "[]") {
                        self?.orders = []
                        self?.currentPage = 1
                        self?.hasMorePages = false
                        print("✅ Empty orders list received")
                        completion()
                        return
                    }
                    
                    // Try to decode the response
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        
                        let response = try decoder.decode(OrdersResponse.self, from: data)
                        
                        if page == 1 {
                            // Replace existing orders if this is the first page
                            self?.orders = response.orders
                        } else {
                            // Append to existing orders if this is a subsequent page
                            self?.orders.append(contentsOf: response.orders)
                        }
                        
                        // Update pagination info
                        self?.currentPage = response.pagination.page
                        self?.hasMorePages = response.pagination.page < response.pagination.pages
                        
                        print("✅ Successfully loaded \(response.orders.count) orders")
                        completion()
                    } catch {
                        // Try to decode as a simple array of orders if the standard format fails
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .iso8601
                            
                            let orders = try decoder.decode([Order].self, from: data)
                            if page == 1 {
                                self?.orders = orders
                            } else {
                                self?.orders.append(contentsOf: orders)
                            }
                            
                            // Set default pagination for array response
                            self?.currentPage = 1
                            self?.hasMorePages = false
                            
                            print("✅ Successfully loaded \(orders.count) orders (array format)")
                            completion()
                            return
                        } catch {
                            // Both decoding attempts failed
                            self?.errorMessage = "Unable to load your orders. Please try again later."
                            print("❌ Decoding Error: \(error)")
                            
                            // More detailed error information
                            if let decodingError = error as? DecodingError {
                                switch decodingError {
                                case .dataCorrupted(let context):
                                    print("Data corrupted: \(context.debugDescription)")
                                    if let underlyingError = context.underlyingError {
                                        print("Underlying error: \(underlyingError)")
                                    }
                                case .keyNotFound(let key, let context):
                                    print("Key not found: \(key), context: \(context.debugDescription)")
                                case .typeMismatch(let type, let context):
                                    print("Type mismatch: expected \(type), context: \(context.debugDescription)")
                                case .valueNotFound(let type, let context):
                                    print("Value not found: expected \(type), context: \(context.debugDescription)")
                                @unknown default:
                                    print("Unknown decoding error")
                                }
                            }
                            
                            completion()
                        }
                    }
                }
            }.resume()
        }
    }
    
    // Create a new order
    func createOrder(userId: String, items: [CartItem], shippingAddress: Address, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Create order request
        struct OrderItemRequest: Codable {
            let product: String
            let quantity: Int
        }
        
        struct OrderRequest: Codable {
            let user: String
            let items: [OrderItemRequest]
            let shippingAddress: Address
        }
        
        // Convert cart items to order items
        let orderItems = items.map { item in
            OrderItemRequest(product: item.product.id, quantity: item.quantity)
        }
        
        let orderRequest = OrderRequest(
            user: userId,
            items: orderItems,
            shippingAddress: shippingAddress
        )
        
        let url = APIConstants.Endpoints.orders
        
        networkService.request(url: url, method: .post, body: orderRequest) { [weak self] (result: Result<OrderCreationResponse, Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    print("✅ Order created successfully: \(response.id ?? response.orderId ?? "Unknown ID")")
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to create order: \(error.localizedDescription)"
                    print("❌ Order creation error: \(error)")
                    completion(false)
                }
            }
        }
    }
} 
