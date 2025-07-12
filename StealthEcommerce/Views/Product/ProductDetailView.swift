//
//  ProductDetail.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct ProductDetailView: View {
    
    let product: Product
    
    @State private var quantity: String = ""
    
    var body: some View {
    
        VStack(alignment: .leading, spacing: 0) {
            Image("hero", bundle: .main).padding()
            Text("\(product.name)").font(.headline).padding()
            Text("$\(String(format: "%.2f", product.price))").foregroundStyle(.gray).padding()
            Text(product.description).padding()
            Text("Quantity").bold().padding()
            TextField("", text: $quantity).background(.gray).cornerRadius(15).padding()
            Spacer()
            Button(action: handleAddToCart) {
                    Text("Add to Cart")
                        .padding(20)
                        .frame(width: 380)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(50)
                
            }.padding()
        }
       
    }
    
    func handleAddToCart() {
        #warning("Todo")
    }
}

#Preview {
    ProductDetailView(product: Product(id: "2", name: "test", description: "test", price: 15.99, category: "test"))
}
