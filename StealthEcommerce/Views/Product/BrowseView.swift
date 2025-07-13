//
//  BrowseView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct BrowseView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                searchBar
                
                // Category filter chips
                if !viewModel.categories.isEmpty {
                    categoryFilterView
                }
                
                if viewModel.isLoading && viewModel.filteredProducts.isEmpty {
                    ProgressView("Loading products...")
                } else if let errorMessage = viewModel.error, viewModel.filteredProducts.isEmpty {
                    Text(errorMessage).foregroundColor(.red)
                } else if viewModel.filteredProducts.isEmpty && !viewModel.searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No products found matching '\(viewModel.searchText)'")
                            .foregroundColor(.gray)
                        Button("Clear Search") {
                            viewModel.clearFilters()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.filteredProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductRowView(product: product)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchProducts()
                    }
                }
            }
            .navigationTitle("Browse Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFilterSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(
                    categories: viewModel.categories,
                    selectedCategory: viewModel.selectedCategory,
                    onSelectCategory: { category in
                        viewModel.filterByCategory(category)
                        showFilterSheet = false
                    },
                    onClearFilters: {
                        viewModel.clearFilters()
                        showFilterSheet = false
                    }
                )
            }
            .onAppear(perform: viewModel.fetchProducts)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search products...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChipView(
                        category: category,
                        isSelected: viewModel.selectedCategory == category,
                        onTap: {
                            if viewModel.selectedCategory == category {
                                viewModel.filterByCategory(nil)
                            } else {
                                viewModel.filterByCategory(category)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("avo").resizable().scaledToFit().frame(width: 100).padding()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                
                Text(product.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 2)
                
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

struct CategoryChipView: View {
    let category: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct FilterSheetView: View {
    let categories: [String]
    let selectedCategory: String?
    let onSelectCategory: (String) -> Void
    let onClearFilters: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Categories")) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            onSelectCategory(category)
                        }) {
                            HStack {
                                Text(category)
                                Spacer()
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Filter Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        onClearFilters()
                    }
                }
            }
        }
    }
}

#Preview {
    BrowseView()
}
