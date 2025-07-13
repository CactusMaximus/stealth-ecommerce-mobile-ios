//
//  OrderHistoryView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var orderViewModel = OrderViewModel()
    @State private var isRetrying = false
    let userId: String
    
    var body: some View {
        VStack {
            if orderViewModel.isLoading {
                ProgressView("Loading orders...")
                    .padding(.top, 40)
            } else if let errorMessage = orderViewModel.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: errorMessage.contains("No order history") ? "cart" : "exclamationmark.triangle")
                        .font(.system(size: 70))
                        .foregroundColor(errorMessage.contains("No order history") ? .blue : .orange)
                    
                    Text("Unable to load orders")
                        .font(.title)
                        .foregroundColor(.primary)
                    
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if errorMessage.contains("No order history") {
                        // Show "Shop Now" button for users with no orders
                        NavigationLink(destination: BrowseView()) {
                            Text("Shop Now")
                                .fontWeight(.medium)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    } else {
                        // Show retry button for other errors
                        Button(action: {
                            retryFetch()
                        }) {
                            HStack {
                                if isRetrying {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                }
                                Text("Try Again")
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isRetrying)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    }
                }
                .padding()
            } else if orderViewModel.orders.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    Text("No orders found")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("Your order history will appear here")
                        .foregroundColor(.secondary)
                    
                    NavigationLink(destination: BrowseView()) {
                        Text("Start Shopping")
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                }
                .padding()
            } else {
                List {
                    ForEach(orderViewModel.orders) { order in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Order #\(order.id.count > 6 ? String(order.id.suffix(6)) : order.id)")
                                    .font(.headline)
                                Spacer()
                                Text(order.formattedDate)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("\(order.items.count) item\(order.items.count == 1 ? "" : "s")")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$\(String(format: "%.2f", order.totalAmount))")
                                    .font(.headline)
                            }
                            
                            HStack {
                                Text("Status:")
                                Text(order.status.capitalized)
                                    .foregroundColor(statusColor(for: order.status))
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await refreshOrders()
                }
            }
        }
        .navigationTitle("Order History")
        .onAppear {
            // Load order history if not already loaded
            if orderViewModel.orders.isEmpty && orderViewModel.errorMessage == nil {
                orderViewModel.fetchOrderHistory(userId: userId)
            }
        }
    }
    
    private func retryFetch() {
        isRetrying = true
        orderViewModel.fetchOrderHistory(userId: userId) {
            isRetrying = false
        }
    }
    
    private func refreshOrders() async {
        // Wrap in Task to convert completion handler to async
        await withCheckedContinuation { continuation in
            orderViewModel.fetchOrderHistory(userId: userId) {
                continuation.resume()
            }
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "processing":
            return .blue
        case "shipped":
            return .purple
        case "delivered":
            return .green
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    NavigationView {
        OrderHistoryView(userId: "user123")
    }
} 