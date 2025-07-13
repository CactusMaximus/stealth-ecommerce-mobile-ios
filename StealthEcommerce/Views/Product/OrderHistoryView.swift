//
//  OrderHistoryView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var orderViewModel = OrderViewModel()
    let userId: String
    
    var body: some View {
        VStack {
            if orderViewModel.isLoading {
                ProgressView("Loading orders...")
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
                }
            } else {
                List {
                    ForEach(orderViewModel.orders) { order in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Order #\(order.id.suffix(6))")
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
                    orderViewModel.fetchOrderHistory(userId: userId, resetPage: true)
                }
            }
        }
        .navigationTitle("Order History")
        .onAppear {
            // For demo purposes, load mock orders instead of real API calls
            orderViewModel.useMockData = true
            orderViewModel.loadMockOrders()
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