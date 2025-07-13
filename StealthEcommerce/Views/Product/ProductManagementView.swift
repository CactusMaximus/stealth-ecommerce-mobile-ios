//
//  ProductManagementView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct ProductManagementView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var showAddProductView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading products...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.products.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cube.box")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No products found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Button("Add Product") {
                            showAddProductView = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.products) { product in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.name)
                                        .font(.headline)
                                    Text("$\(String(format: "%.2f", product.price))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Stock: \(product.stock)")
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Edit product (to be implemented)
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing, 8)
                                
                                Button(action: {
                                    deleteProduct(product)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .refreshable {
                        viewModel.fetchProducts()
                    }
                }
            }
            .navigationTitle("Product Management")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddProductView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddProductView, onDismiss: {
                viewModel.fetchProducts()
            }) {
                AddProductView()
            }
            .onAppear {
                viewModel.fetchProducts()
            }
        }
    }
    
    private func deleteProduct(_ product: Product) {
        guard let id = product.id as? String else {
            print("Error: Product ID is not a string")
            return
        }
        
        viewModel.deleteProduct(productId: id) { success in
            if success {
                // Product deleted successfully
                print("Product deleted: \(product.name)")
            }
        }
    }
}

#Preview {
    ProductManagementView()
} 