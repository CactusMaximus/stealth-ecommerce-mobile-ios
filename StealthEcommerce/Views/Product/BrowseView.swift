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
    @State private var searchText = ""
    @State private var showAddProductView = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
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
            .navigationTitle("browse.title".localized)
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
        .padding(.top, 8)
    }
    
    private func filterProducts() {
        if searchText.isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func fetchProducts() {
        isLoading = true
        errorMessage = nil
        let url = APIConstants.Endpoints.products
        NetworkService.shared.request(url: url, method: .get, body: Optional<Product>.none, headers: [:]) { (result: Result<[Product], Error>) in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let products):
                    self.products = products
                    self.filterProducts() // Apply any existing search filter
                case .failure(let error):
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
