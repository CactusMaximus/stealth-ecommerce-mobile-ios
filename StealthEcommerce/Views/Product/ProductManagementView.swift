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
    @State private var showDeleteConfirmation = false
    @State private var productToDelete: Product? = nil
    @State private var searchText = ""
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return viewModel.products
        } else {
            return viewModel.products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("product_management.search".localized, text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if viewModel.isLoading {
                    ProgressView("product_management.loading".localized)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if filteredProducts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text(searchText.isEmpty ? "product_management.no_products".localized : "product_management.no_results".localized(with: searchText))
                            .foregroundColor(.gray)
                        
                        if !searchText.isEmpty {
                            Button("product_management.clear_search".localized) {
                                searchText = ""
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                HStack(spacing: 12) {
                                    // Product image
                                    AsyncImage(url: URL(string: product.imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            Image(systemName: "photo")
                                                .frame(width: 60, height: 60)
                                                .background(Color.gray.opacity(0.2))
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        case .failure:
                                            Image(systemName: "photo.fill")
                                                .frame(width: 60, height: 60)
                                                .background(Color.gray.opacity(0.2))
                                        @unknown default:
                                            Image(systemName: "photo")
                                                .frame(width: 60, height: 60)
                                        }
                                    }
                                    
                                    // Product details
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.name)
                                            .font(.headline)
                                        
                                        Text("$\(String(format: "%.2f", product.price))")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        
                                        Text("product_management.stock".localized(with: product.stock))
                                            .font(.caption)
                                            .foregroundColor(product.stock > 0 ? .green : .red)
                                    }
                                    
                                    Spacer()
                                    
                                    // Delete button
                                    Button(action: {
                                        productToDelete = product
                                        showDeleteConfirmation = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchProducts()
                    }
                }
            }
            .navigationTitle("product_management.title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddProductView = true
                    }) {
                        Label("product_management.add".localized, systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddProductView, onDismiss: {
                viewModel.fetchProducts()
            }) {
                AddProductView()
            }
            .alert("product_management.delete.title".localized, isPresented: $showDeleteConfirmation) {
                Button("common.cancel".localized, role: .cancel) { }
                Button("common.delete".localized, role: .destructive) {
                    if let product = productToDelete {
                        deleteProduct(product)
                    }
                }
            } message: {
                Text("product_management.delete.confirmation".localized)
            }
            .onAppear {
                viewModel.fetchProducts()
            }
        }
    }
    
    private func deleteProduct(_ product: Product) {
        viewModel.deleteProduct(productId: product.id) { success in
            if success {
                // Product was successfully deleted and removed from the array
                // No need to do anything else as the UI will update automatically
            } else {
                // Error message is already set in the view model
            }
        }
    }
}

#Preview {
    ProductManagementView()
        .environmentObject(LocalizationManager.shared)
} 