//
//  CartView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShippingAddressView = false
    @State private var proceedToConfirmation = false
    
    // Hardcoded user ID for demo purposes - in a real app, this would come from user authentication
    let userId = "65f5a1d2e1b7c2a3d4f5e6a7"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if cartViewModel.items.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Text("cart.empty".localized)
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Button("cart.continue_shopping".localized) {
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
                    Text("cart.summary".localized).font(.title2).bold()
                    HStack {
                        Text("cart.subtotal".localized).foregroundStyle(.gray)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.subtotal))")
                    }
                    HStack {
                        Text("cart.shipping".localized).foregroundStyle(.gray)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.shippingCost))")
                    }
                    
                    HStack {
                        Text("cart.total".localized).foregroundStyle(.gray)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.total))")
                            .font(.headline)
                    }
                }
                .padding()
                
                Button(action: {
                    showingShippingAddressView = true
                }) {
                    Text("cart.proceed_checkout".localized)
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
        .navigationTitle("cart.title".localized)
        .sheet(isPresented: $showingShippingAddressView) {
            ShippingAddressView {
                proceedToConfirmation = true
            }
            .environmentObject(cartViewModel)
        }
        .background(
            NavigationLink(
                destination: OrderConfirmationView(userId: userId)
                    .environmentObject(cartViewModel),
                isActive: $proceedToConfirmation
            ) {
                EmptyView()
            }
        )
    }
    
    func cartItemView(for item: CartItem) -> some View {
        HStack {
            Image("avo").resizable().scaledToFit().frame(width: 80).padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)
                Text("cart.quantity".localized(with: item.quantity))
                    .foregroundStyle(.gray)
                Text("cart.price_each".localized(with: String(format: "%.2f", item.product.price)))
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text("$\(String(format: "%.2f", item.total))")
                .bold()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        CartView()
            .environmentObject(CartViewModel())
            .environmentObject(LocalizationManager.shared)
    }
}

