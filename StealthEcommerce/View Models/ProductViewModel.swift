//
//  ProductViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/12.
//

import Foundation
import Combine

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var searchText = ""
    @Published var selectedCategory: String? = nil
    @Published var categories: [String] = []
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkService = NetworkService.shared) {
        self.networkService = networkService
        
        // Set up search and filter publishers
        setupPublishers()
    }
    
    private func setupPublishers() {
        // Combine the search text and category filter to filter products
        Publishers.CombineLatest($searchText, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, selectedCategory) in
                self?.filterProducts(searchText: searchText, category: selectedCategory)
            }
            .store(in: &cancellables)
        
        // When products change, update filtered products and extract categories
        $products
            .sink { [weak self] products in
                guard let self = self else { return }
                self.filteredProducts = products
                self.extractCategories(from: products)
            }
            .store(in: &cancellables)
    }
    
    func fetchProducts() {
        isLoading = true
        error = nil
        
        networkService.request(
            url: APIConstants.Endpoints.products,
            method: .get,
            body: Optional<EmptyRequest>.none
        ) { [weak self] (result: Result<[Product], Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let products):
                    self?.products = products
                    // Filtered products will be updated via the publisher
                    
                case .failure(let error):
                    self?.error = "Failed to load products: \(error.localizedDescription)"
                    print("❌ Error fetching products: \(error)")
                }
            }
        }
    }
    
    func searchProducts(query: String) {
        searchText = query
    }
    
    func filterByCategory(_ category: String?) {
        selectedCategory = category
    }
    
    private func filterProducts(searchText: String, category: String?) {
        let searchTextLowercased = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        filteredProducts = products.filter { product in
            // Apply category filter if selected
            let categoryMatch = category == nil || product.category == category
            
            // Apply search text filter if not empty
            let searchMatch = searchTextLowercased.isEmpty || 
                product.name.lowercased().contains(searchTextLowercased) ||
                product.description.lowercased().contains(searchTextLowercased)
            
            return categoryMatch && searchMatch
        }
    }
    
    private func extractCategories(from products: [Product]) {
        // Extract unique categories
        let uniqueCategories = Set(products.map { $0.category })
        categories = Array(uniqueCategories).sorted()
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
    }
} 