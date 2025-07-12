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
    
        VStack(alignment: .leading, spacing: 0) {
            Image("hero", bundle: .main).padding()
            Text("\(product.name)").font(.headline).padding()
            Text("$\(String(format: "%.2f", product.price))").foregroundStyle(.gray).padding()
            Text(product.description).padding()
            Text("Quantity").bold().padding()
            TextField("", text: $quantity)
                .keyboardType(.numberPad)
                .background(.gray)
                .cornerRadius(15)
                .padding()
            Spacer()
            Button(action: handleAddToCart) {
                    Text("Add to Cart")
                        .padding(20)
                        .frame(width: 380)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(50)
                
            }.padding()
            
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
       
    }
    
    func handleAddToCart() {
        guard let quantityInt = Int(quantity), quantityInt > 0 else {
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
    ProductDetailView(product: Product(id: "2", name: "test", description: "test", price: 15.99, category: "test"))
        .environmentObject(CartViewModel())
}
