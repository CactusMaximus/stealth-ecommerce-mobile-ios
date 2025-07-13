//
//  OrderHistoryView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var orderViewModel = OrderViewModel()
    @State private var showMockDataAlert = false
    let userId: String
    
    var body: some View {
        ZStack {
            if orderViewModel.isLoading && orderViewModel.orders.isEmpty {
                ProgressView("Loading orders...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if orderViewModel.orders.isEmpty && orderViewModel.error != nil {
                VStack(spacing: 20) {
                    Text("No orders found")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text(orderViewModel.error ?? "Unknown error")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Use Mock Data") {
                        orderViewModel.useMockData = true
                        orderViewModel.loadMockOrders()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Try Again with API") {
                        orderViewModel.fetchOrderHistory(userId: userId, resetPage: true)
                    }
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
                .padding()
            } else {
                VStack {
                    if orderViewModel.useMockData {
                        HStack {
                            Text("Using mock data")
                                .foregroundColor(.orange)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.2))
                                )
                            
                            Spacer()
                            
                            Button("Use Real API") {
                                showMockDataAlert = true
                            }
                            .font(.caption)
                            .alert(isPresented: $showMockDataAlert) {
                                Alert(
                                    title: Text("Switch to Real API?"),
                                    message: Text("The server may return a large response that could cause the app to crash. Continue?"),
                                    primaryButton: .destructive(Text("Yes, Try API")) {
                                        orderViewModel.useMockData = false
                                        orderViewModel.fetchOrderHistory(userId: userId, resetPage: true)
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    List {
                        ForEach(orderViewModel.orders) { order in
                            NavigationLink(destination: OrderDetailView(order: order)) {
                                OrderRowView(order: order)
                            }
                        }
                        
                        if orderViewModel.hasMorePages {
                            HStack {
                                Spacer()
                                if orderViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .onAppear {
                                            // This will trigger when the progress view appears
                                            orderViewModel.loadNextPage(userId: userId)
                                        }
                                } else {
                                    Button("Load More") {
                                        orderViewModel.loadNextPage(userId: userId)
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        if orderViewModel.useMockData {
                            orderViewModel.loadMockOrders()
                        } else {
                            orderViewModel.fetchOrderHistory(userId: userId, resetPage: true)
                        }
                    }
                }
                
                if let error = orderViewModel.error, !orderViewModel.orders.isEmpty {
                    VStack {
                        Spacer()
                        Text(error)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Order History")
        .onAppear {
            if orderViewModel.orders.isEmpty {
                // Use real API data by default
                orderViewModel.useMockData = false
                orderViewModel.fetchOrderHistory(userId: userId, resetPage: true)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !orderViewModel.orders.isEmpty {
                    Button(action: {
                        if !orderViewModel.useMockData {
                            showMockDataAlert = false
                            orderViewModel.toggleMockData()
                        } else {
                            showMockDataAlert = true
                        }
                    }) {
                        Label(
                            orderViewModel.useMockData ? "Use Real Data" : "Use Mock Data",
                            systemImage: orderViewModel.useMockData ? "network" : "doc.text"
                        )
                    }
                }
            }
        }
    }
}

struct OrderRowView: View {
    let order: Order
    
    var body: some View {
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

struct OrderDetailView: View {
    let order: Order
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Order info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order #\(order.id.suffix(6))")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Placed on \(order.formattedDate)")
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("Status:")
                        Text(order.status.capitalized)
                            .fontWeight(.semibold)
                            .foregroundColor(statusColor(for: order.status))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
                
                // Items
                VStack(alignment: .leading, spacing: 10) {
                    Text("Items")
                        .font(.headline)
                    
                    ForEach(order.items) { item in
                        HStack {
                            Image("avo").resizable().scaledToFit().frame(width: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.product.name)
                                    .fontWeight(.medium)
                                Text("Quantity: \(item.quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", item.total))")
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 8)
                        
                        if item.id != order.items.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
                
                // Shipping address
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shipping Address")
                        .font(.headline)
                    
                    Text(order.shippingAddress.street)
                    Text("\(order.shippingAddress.city), \(order.shippingAddress.state) \(order.shippingAddress.zipCode)")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
                
                // Order summary
                VStack(spacing: 8) {
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("$\(String(format: "%.2f", order.totalAmount))")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .background(Color(.systemGroupedBackground))
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