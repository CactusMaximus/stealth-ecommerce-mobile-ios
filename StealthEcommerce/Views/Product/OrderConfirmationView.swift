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
                
                if let error = orderViewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Confirm Order")
        .navigationBarBackButtonHidden(orderViewModel.orderSuccess)
        .alert(isPresented: .constant(orderViewModel.orderSuccess)) {
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
    }
    
    private func placeOrder() {
        orderViewModel.createOrder(
            userId: userId,
            cartItems: cartViewModel.items,
            shippingAddress: cartViewModel.shippingAddress
        ) { success in
            if success {
                // Clear the cart after successful order
                cartViewModel.clearCart()
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