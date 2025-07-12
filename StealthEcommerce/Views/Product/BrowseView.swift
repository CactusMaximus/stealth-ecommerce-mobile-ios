//
//  BrowseView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct BrowseView: View {
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading products...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else {
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
                            }
                        }
                    }
                }
            }
            .onAppear(perform: fetchProducts)
        }
    }
    
    private func fetchProducts() {
        isLoading = true
        errorMessage = nil
        let url = "http://localhost:3000/api/products" // Change to your server IP if needed
        NetworkService.shared.request(url: url, method: .get, body: Optional<Product>.none, headers: [:]) { (result: Result<[Product], Error>) in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let products):
                    self.products = products
                case .failure(let error):
                    self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    BrowseView()
}
