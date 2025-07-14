//
//  BrowseView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct BrowseView: View {
    @State private var products: [Product] = []
    @State private var filteredProducts: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchText: String
    @State private var showAddProductView = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    // Category filter and search query
    var selectedCategory: String?
    
    init(selectedCategory: String? = nil, searchQuery: String = "") {
        self.selectedCategory = selectedCategory
        _searchText = State(initialValue: searchQuery)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar at the top
                searchBar
                
                if isLoading {
                    ProgressView("browse.loading".localized)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else if filteredProducts.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("browse.no_results".localized(with: searchText))
                            .foregroundColor(.gray)
                        Button("browse.clear_search".localized) {
                            searchText = ""
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    Spacer()
                } else if filteredProducts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text(selectedCategory != nil ? 
                             "No products found in the \(selectedCategory!.capitalized) category" : 
                             "No products available")
                            .foregroundColor(.gray)
                        
                        if !products.isEmpty {
                            Text("Available categories: \(Array(Set(products.map { $0.category })).joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button("Refresh") {
                            fetchProducts()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredProducts) { product in
                            VStack (alignment: .leading, spacing: 20) {
                                HStack(alignment: .center, spacing: 0) {
                                    AsyncImage(url: URL(string: product.imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            Image("avo").resizable().scaledToFit().frame(width: 100).padding()
                                        case .success(let image):
                                            image.resizable().scaledToFit().frame(width: 100).padding()
                                        case .failure:
                                            Image("avo").resizable().scaledToFit().frame(width: 100).padding()
                                        @unknown default:
                                            Image("avo").resizable().scaledToFit().frame(width: 100).padding()
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(product.name)")
                                            .font(.headline)
                                        Text("$\(String(format: "%.2f", product.price))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("browse.stock".localized(with: product.stock))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    NavigationLink(destination: ProductDetailView(product: product)) {
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        fetchProducts()
                    }
                }
            }
            .navigationTitle(selectedCategory != nil ? selectedCategory!.capitalized : "browse.title".localized)
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
                fetchProducts()
            }) {
                AddProductView()
            }
            .onAppear(perform: fetchProducts)
            .onChange(of: searchText) { _, newValue in
                filterProducts()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("browse.search_placeholder".localized, text: $searchText)
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
        .padding(.vertical, 8)
    }
    
    private func filterProducts() {
        if searchText.isEmpty {
            // If we have a selected category, filter by that
            if let category = selectedCategory {
                // Try to match by category ID first, then by name
                filteredProducts = products.filter { product in
                    // Case-insensitive comparison for both ID and name
                    product.category.lowercased() == category.lowercased() ||
                    product.category.lowercased().contains(category.lowercased())
                }
                
                // If no products found, print debug info
                if filteredProducts.isEmpty {
                    print("No products found for category: \(category)")
                    print("Available categories in products: \(products.map { $0.category }.joined(separator: ", "))")
                }
            } else {
                filteredProducts = products
            }
        } else {
            // Filter by search text AND category if applicable
            var filtered = products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText)
            }
            
            // If we have a selected category, further filter the results
            if let category = selectedCategory {
                filtered = filtered.filter { product in
                    product.category.lowercased() == category.lowercased() ||
                    product.category.lowercased().contains(category.lowercased())
                }
            }
            
            filteredProducts = filtered
        }
    }
    
    private func fetchProducts() {
        isLoading = true
        errorMessage = nil
        let url = APIConstants.Endpoints.products
        
        print("🔍 Fetching products from: \(url)")
        if let selectedCategory = selectedCategory {
            print("🔍 Selected category: \(selectedCategory)")
        }
        
        NetworkService.shared.request(url: url, method: .get, body: Optional<Product>.none, headers: [:]) { (result: Result<[Product], Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let products):
                    self.products = products
                    print("✅ Fetched \(products.count) products")
                    
                    // Log all unique categories
                    let uniqueCategories = Set(products.map { $0.category })
                    print("📊 Available categories: \(uniqueCategories.joined(separator: ", "))")
                    
                    self.filterProducts() // Apply any existing search filter and category filter
                    
                    // Log filtered results
                    if let selectedCategory = self.selectedCategory {
                        print("🔍 After filtering for '\(selectedCategory)': \(self.filteredProducts.count) products")
                    }
                case .failure(let error):
                    print("❌ Error fetching products: \(error.localizedDescription)")
                    self.errorMessage = "browse.error.loading".localized(with: error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    BrowseView()
        .environmentObject(LocalizationManager.shared)
}
