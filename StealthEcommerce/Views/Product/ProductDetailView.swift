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
            Text("$15.99").foregroundStyle(.gray).padding()
            Text("The Diamond Pickaxe is the ultimate tool for mining in Minecraft. It's crafted from diamonds and offers superior durability and efficiency compared to other axes. This pickaxe can mine all ores.").padding()
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
    ProductDetailView(product: Product(id: "2", name: "test", description: "test", price: "test", category: "test"))
}
