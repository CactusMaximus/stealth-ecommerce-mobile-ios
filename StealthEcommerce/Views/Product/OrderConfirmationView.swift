//
//  OrderConfirmationView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct OrderConfirmationView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @StateObject private var orderViewModel = OrderViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    let userId: String
    
    @State private var showingOrderHistory = false
    @State private var orderSuccess = false
    @State private var orderError: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Order summary header
                Text("Order Summary")
                    .font(.title)
                    .padding(.top)
                
                // Items in cart
                ForEach(cartViewModel.items) { item in
                    HStack {
                        Image("avo").resizable().scaledToFit().frame(width: 60)
                        VStack(alignment: .leading) {
                            Text(item.product.name)
                                .font(.headline)
                            Text("Quantity: \(item.quantity)")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("$\(String(format: "%.2f", item.total))")
                            .bold()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                }
                
                // Shipping address
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shipping Address")
                        .font(.headline)
                    
                    Text(cartViewModel.shippingAddress.street)
                    Text("\(cartViewModel.shippingAddress.city), \(cartViewModel.shippingAddress.state) \(cartViewModel.shippingAddress.zipCode)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
                
                // Order total
                VStack(spacing: 8) {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.subtotal))")
                    }
                    
                    HStack {
                        Text("Shipping")
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.shippingCost))")
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.total))")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 1)
                
                // Place order button
                Button(action: placeOrder) {
                    if orderViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Place Order")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.yellow)
                .foregroundColor(.black)
                .cornerRadius(10)
                .disabled(orderViewModel.isLoading)
                
                if let error = orderError {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Confirm Order")
        .navigationBarBackButtonHidden(orderSuccess)
        .alert(isPresented: $orderSuccess) {
            Alert(
                title: Text("Order Placed!"),
                message: Text("Your order has been successfully placed."),
                dismissButton: .default(Text("View Order History")) {
                    showingOrderHistory = true
                }
            )
        }
        .background(
            NavigationLink(
                destination: OrderHistoryView(userId: userId),
                isActive: $showingOrderHistory
            ) {
                EmptyView()
            }
        )
        .onAppear {
            // Reset error state
            orderError = nil
            // Track checkout page view
            AnalyticsManager.shared.trackEvent(
                name: "begin_checkout",
                parameters: [
                    "item_count": cartViewModel.items.count,
                    "value": cartViewModel.total
                ]
            )
        }
        .trackScreenView(screenName: "Order Confirmation")
        .onChange(of: orderViewModel.errorMessage) { newValue in
            if let errorMessage = newValue {
                orderError = "Failed to create order: \(errorMessage)"
                
                // Check for specific network errors
                if errorMessage.contains("NetworkError") {
                    orderError = "Network error: Please check your internet connection and try again."
                } else if errorMessage.contains("serverError") {
                    // Extract the actual error message from the serverError
                    if let range = errorMessage.range(of: "message: \"") {
                        let startIndex = range.upperBound
                        if let endRange = errorMessage[startIndex...].range(of: "\", code:") {
                            let endIndex = endRange.lowerBound
                            let actualMessage = String(errorMessage[startIndex..<endIndex])
                            orderError = "Server error: \(actualMessage)"
                        }
                    }
                }
            }
        }
    }
    
    private func placeOrder() {
        // Clear previous errors
        orderError = nil
        
        orderViewModel.createOrder(
            userId: userId,
            items: cartViewModel.items,
            shippingAddress: cartViewModel.shippingAddress
        ) { success in
            if success {
                // Track purchase event
                AnalyticsManager.shared.trackEvent(
                    name: "purchase_complete",
                    parameters: [
                        "value": cartViewModel.total,
                        "currency": "USD",
                        "payment_type": "standard"
                    ]
                )
                
                // Clear the cart after successful order
                cartViewModel.clearCart()
                orderSuccess = true
            } else if let errorMessage = orderViewModel.errorMessage {
                orderError = errorMessage
                
                // Track checkout error
                AnalyticsManager.shared.trackEvent(
                    name: "checkout_error",
                    parameters: [
                        "error_message": errorMessage
                    ]
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        OrderConfirmationView(userId: "user123")
            .environmentObject(CartViewModel())
    }
} 