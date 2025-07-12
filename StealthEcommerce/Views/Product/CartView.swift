//
//  CartView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCheckoutSuccess = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if cartViewModel.items.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Text("Your cart is empty")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Button("Continue Shopping") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(50)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(cartViewModel.items) { item in
                        cartItemView(for: item)
                    }
                    .onDelete(perform: cartViewModel.removeItem)
                }
                .listStyle(PlainListStyle())
                
                VStack(spacing: 10) {
                    Text("Summary").font(.title2).bold()
                    HStack {
                        Text("Subtotal").foregroundStyle(.gray)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.subtotal))")
                    }
                    HStack {
                        Text("Shipping").foregroundStyle(.gray)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.shippingCost))")
                    }
                    
                    HStack {
                        Text("Total").foregroundStyle(.gray)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.total))")
                            .font(.headline)
                    }
                }
                .padding()
                
                Button(action: handleCheckout) {
                    Text("Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(50)
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
        .navigationTitle("Cart")
        .alert(isPresented: $showingCheckoutSuccess) {
            Alert(
                title: Text("Order Placed!"),
                message: Text("Your order has been successfully placed."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    func cartItemView(for item: CartItem) -> some View {
        HStack {
            Image("avo").resizable().scaledToFit().frame(width: 80).padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)
                Text("Quantity: \(item.quantity)")
                    .foregroundStyle(.gray)
                Text("$\(String(format: "%.2f", item.product.price)) each")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text("$\(String(format: "%.2f", item.total))")
                .bold()
        }
        .padding(.vertical, 8)
    }
    
    func handleCheckout() {
        cartViewModel.checkout()
        showingCheckoutSuccess = true
    }
}

#Preview {
    NavigationView {
        CartView()
            .environmentObject(CartViewModel())
    }
}

