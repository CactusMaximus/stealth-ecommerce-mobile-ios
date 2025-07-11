//
//  BrowseView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct BrowseView: View {
    @State private var products = [
        Product(id: "1", name: "test", description: "test", price: "test", category: "test"),
        Product(id: "2", name: "test2", description: "test", price: "test", category: "test"),
        Product(id: "3", name: "test3", description: "test", price: "test", category: "test"),
        Product(id: "4", name: "test4", description: "test", price: "test", category: "test"),
        Product(id: "5", name: "test5", description: "test", price: "test", category: "test"),
        Product(id: "6", name: "test6", description: "test", price: "test", category: "test"),
        Product(id: "7", name: "test7", description: "test", price: "test", category: "test")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(products) { product in
                    VStack (alignment: .leading, spacing: 20) {
                        HStack(alignment: .center, spacing: 0) {
                            Image("avo").resizable().scaledToFit().frame(width: 100).padding()
                            
                            Text("\(product.name)")
                            Spacer()
                            NavigationLink(destination: ProductDetailView(product: product)) {
                            }
                        }
                        
                    }}
            }
        }
    }
}

#Preview {
    BrowseView()
}
