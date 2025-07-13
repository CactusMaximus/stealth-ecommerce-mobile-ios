//
//  OrderViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation
import SwiftUI

class OrderViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var orderSuccess = false
    @Published var orders: [Order] = []
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var hasMorePages = false
    @Published var useMockData = false
    
    private let networkService: NetworkService
    private let pageSize = 2 // Reduced from 5 to 2 to handle smaller responses
    
    // Timer to handle timeout for API calls
    private var loadingTimer: Timer?
    private let timeoutInterval: TimeInterval = 15.0 // 15 seconds timeout
    
    init(networkService: NetworkService = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // Create a new order
    func createOrder(userId: String, cartItems: [CartItem], shippingAddress: Address, completion: @escaping (Bool) -> Void) {
        isLoading = true
        startLoadingTimer()
        
        // Convert CartItems to OrderItems
        let orderItems = cartItems.map { cartItem in
            return OrderItemRequest(
                product: cartItem.product.id,
                quantity: cartItem.quantity,
                price: cartItem.product.price
            )
        }
        
        // Calculate total amount (used in the OrderRequest below)
        let totalAmount = cartItems.reduce(0) { $0 + $1.total }
        
        // Create order request
        let orderRequest = OrderRequest(
            user: userId,
            items: orderItems,
            shippingAddress: shippingAddress,
            totalAmount: totalAmount  // Add totalAmount to the request
        )
        
        // Send API request
        networkService.request(
            url: APIConstants.Endpoints.orders,
            method: .post,
            body: orderRequest
        ) { [weak self] (result: Result<Order, Error>) in
            self?.stopLoadingTimer()
            
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let order):
                    print("✅ Order created successfully: \(order.id)")
                    self?.orderSuccess = true
                    completion(true)
                    
                case .failure(let error):
                    print("❌ Failed to create order: \(error)")
                    self?.error = "Failed to create order: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    // Fetch order history for a user
    func fetchOrderHistory(userId: String, resetPage: Bool = false) {
        if resetPage {
            currentPage = 1
            orders = []
        }
        
        // If we're already using mock data, just load it directly
        if useMockData {
            loadMockOrders()
            return
        }
        
        isLoading = true
        startLoadingTimer()
        
        // Construct URL with pagination and user filter
        let url = "\(APIConstants.Endpoints.orders)?user=\(userId)&page=\(currentPage)&limit=\(pageSize)"
        
        networkService.request(
            url: url,
            method: .get,
            body: EmptyRequest()
        ) { [weak self] (result: Result<OrdersResponse, Error>) in
            self?.stopLoadingTimer()
            
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    if resetPage {
                        self?.orders = response.orders
                    } else {
                        self?.orders.append(contentsOf: response.orders)
                    }
                    
                    self?.totalPages = response.pagination.pages
                    self?.hasMorePages = self?.currentPage ?? 1 < response.pagination.pages
                    
                case .failure(let error):
                    print("❌ Failed to fetch orders: \(error)")
                    
                    // Check for specific "resource exceeds maximum size" error
                    let nsError = error as NSError
                    if nsError.domain == NSURLErrorDomain && nsError.code == -1103 {
                        self?.error = "The server response is too large. Please try again or use mock data."
                    } else {
                        self?.error = "Failed to fetch orders: \(error.localizedDescription)"
                    }
                    
                    // Don't automatically switch to mock data
                    // Keep the error visible to the user
                }
            }
        }
    }
    
    // Load next page of orders
    func loadNextPage(userId: String) {
        if !isLoading && hasMorePages {
            currentPage += 1
            fetchOrderHistory(userId: userId)
        }
    }
    
    // Toggle between mock data and real API
    func toggleMockData() {
        useMockData.toggle()
        if useMockData {
            loadMockOrders()
        } else {
            orders = []
            currentPage = 1
            totalPages = 1
            hasMorePages = false
        }
    }
    
    // Handle timeout for API calls
    private func startLoadingTimer() {
        loadingTimer = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                if self?.isLoading == true {
                    self?.isLoading = false
                    self?.error = "Request timed out. Please try again."
                    
                    // Don't automatically switch to mock data on timeout
                }
            }
        }
    }
    
    private func stopLoadingTimer() {
        loadingTimer?.invalidate()
        loadingTimer = nil
    }
    
    // Load mock data for testing when API fails
    func loadMockOrders() {
        print("📝 Loading mock order data")
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            let mockAddress = Address(
                street: "123 Main St",
                city: "San Francisco",
                state: "CA",
                zipCode: "94105"
            )
            
            let mockUser = UserInfo(
                id: "user123",
                email: "test@example.com",
                firstName: "John",
                lastName: "Doe"
            )
            
            // Create a variety of mock products
            let mockProducts = [
                ProductInOrder(id: "prod1", name: "Premium Avocado", price: 5.99, imageUrl: nil),
                ProductInOrder(id: "prod2", name: "Organic Banana", price: 2.99, imageUrl: nil),
                ProductInOrder(id: "prod3", name: "Fresh Strawberries", price: 4.50, imageUrl: nil),
                ProductInOrder(id: "prod4", name: "Whole Grain Bread", price: 3.75, imageUrl: nil),
                ProductInOrder(id: "prod5", name: "Free Range Eggs", price: 6.25, imageUrl: nil)
            ]
            
            // Create more varied mock orders
            var mockOrders = [Order]()
            
            // Order 1 - Delivered
            mockOrders.append(
                Order(
                    id: "order1",
                    user: mockUser,
                    items: [
                        OrderItem(product: mockProducts[0], quantity: 2, price: mockProducts[0].price),
                        OrderItem(product: mockProducts[1], quantity: 3, price: mockProducts[1].price)
                    ],
                    totalAmount: 20.95,
                    status: "delivered",
                    shippingAddress: mockAddress,
                    createdAt: "2025-07-10T12:00:00.000Z"
                )
            )
            
            // Order 2 - Processing
            mockOrders.append(
                Order(
                    id: "order2",
                    user: mockUser,
                    items: [
                        OrderItem(product: mockProducts[2], quantity: 2, price: mockProducts[2].price),
                        OrderItem(product: mockProducts[3], quantity: 1, price: mockProducts[3].price)
                    ],
                    totalAmount: 12.75,
                    status: "processing",
                    shippingAddress: mockAddress,
                    createdAt: "2025-07-05T15:30:00.000Z"
                )
            )
            
            // Order 3 - Shipped
            mockOrders.append(
                Order(
                    id: "order3",
                    user: mockUser,
                    items: [
                        OrderItem(product: mockProducts[4], quantity: 2, price: mockProducts[4].price),
                        OrderItem(product: mockProducts[0], quantity: 1, price: mockProducts[0].price)
                    ],
                    totalAmount: 18.49,
                    status: "shipped",
                    shippingAddress: mockAddress,
                    createdAt: "2025-06-28T09:15:00.000Z"
                )
            )
            
            // Order 4 - Pending
            mockOrders.append(
                Order(
                    id: "order4",
                    user: mockUser,
                    items: [
                        OrderItem(product: mockProducts[1], quantity: 4, price: mockProducts[1].price),
                        OrderItem(product: mockProducts[3], quantity: 2, price: mockProducts[3].price)
                    ],
                    totalAmount: 19.46,
                    status: "pending",
                    shippingAddress: mockAddress,
                    createdAt: "2025-07-11T08:45:00.000Z"
                )
            )
            
            self.orders = mockOrders
            self.totalPages = 1
            self.hasMorePages = false
            self.isLoading = false
            self.error = nil
        }
    }
}

// Request models
struct OrderRequest: Codable {
    let user: String
    let items: [OrderItemRequest]
    let shippingAddress: Address
    let totalAmount: Double // Added totalAmount to the request
}

struct OrderItemRequest: Codable {
    let product: String
    let quantity: Int
    let price: Double
} 