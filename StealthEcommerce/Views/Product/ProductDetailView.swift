//
//  ProductDetail.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct ProductDetailView: View {
    
    let product: Product
    
    @State private var quantity: String = "1"
    @State private var showingAddedToast = false
    @EnvironmentObject private var cartViewModel: CartViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product image
                AsyncImage(url: URL(string: product.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 250)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    case .failure:
                        Image("hero")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .overlay(
                                Text("Image failed to load")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                            )
                    @unknown default:
                        Image("hero")
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(product.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    HStack {
                        Text("Category:")
                            .fontWeight(.medium)
                        Text(product.category)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("In Stock:")
                            .fontWeight(.medium)
                        Text("\(product.stock) units")
                            .foregroundColor(product.stock > 0 ? .green : .red)
                    }
                    
                    Divider()
                    
                    Text("Description")
                        .font(.headline)
                    
                    Text(product.description)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("Quantity")
                        .font(.headline)
                    
                    HStack {
                        Button(action: {
                            decrementQuantity()
                        }) {
                            Image(systemName: "minus.circle")
                                .font(.title2)
                        }
                        .disabled(Int(quantity) == 1)
                        
                        TextField("", text: $quantity)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onChange(of: quantity) { _, newValue in
                                validateQuantity(newValue)
                            }
                        
                        Button(action: {
                            incrementQuantity()
                        }) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                        }
                        .disabled(Int(quantity) ?? 1 >= product.stock)
                    }
                    
                    if product.stock <= 5 && product.stock > 0 {
                        Text("Only \(product.stock) left in stock - order soon!")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                    } else if product.stock == 0 {
                        Text("Out of stock")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: handleAddToCart) {
                    Text("Add to Cart")
                        .fontWeight(.bold)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(product.stock > 0 ? Color.yellow : Color.gray)
                        .foregroundColor(.black)
                        .cornerRadius(50)
                }
                .disabled(product.stock == 0)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.vertical)
            
            if showingAddedToast {
                Text("Added to cart!")
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showingAddedToast = false
                            }
                        }
                    }
            }
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func validateQuantity(_ value: String) {
        if let intValue = Int(value) {
            if intValue < 1 {
                quantity = "1"
            } else if intValue > product.stock {
                quantity = "\(product.stock)"
            }
        } else if value.isEmpty {
            quantity = "1"
        } else {
            // Remove non-numeric characters
            quantity = value.filter { "0123456789".contains($0) }
            if quantity.isEmpty {
                quantity = "1"
            }
        }
    }
    
    private func incrementQuantity() {
        if let current = Int(quantity), current < product.stock {
            quantity = "\(current + 1)"
        }
    }
    
    private func decrementQuantity() {
        if let current = Int(quantity), current > 1 {
            quantity = "\(current - 1)"
        }
    }
    
    func handleAddToCart() {
        guard let quantityInt = Int(quantity), quantityInt > 0, quantityInt <= product.stock else {
            // Handle invalid quantity
            quantity = "1"
            return
        }
        
        // Add to cart using the CartViewModel
        cartViewModel.addToCart(product: product, quantity: quantityInt)
        
        // Show toast message
        withAnimation {
            showingAddedToast = true
        }
        
        // Reset quantity field
        quantity = "1"
    }
}

#Preview {
    ProductDetailView(product: Product(
        id: "2",
        name: "Wireless Headphones",
        description: "Premium wireless headphones with noise cancellation and 30-hour battery life.",
        price: 149.99,
        category: "Electronics",
        stock: 15,
        imageUrl: "https://example.com/headphones.jpg"
    ))
    .environmentObject(CartViewModel())
}
