//
//  ProductViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation
import SwiftUI

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // For product creation
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var price: String = ""
    @Published var category: String = ""
    @Published var stock: String = ""
    @Published var imageUrl: String = ""
    @Published var showSuccessAlert = false
    
    private let networkService = NetworkService.shared
    
    // Available product categories
    let categories = [
        "tools", "armor", "resources", "food", "electronics", "clothing", 
        "home-kitchen", "books", "toys", "beauty", "sports", "grocery"
    ]
    
    // Fetch all products
    func fetchProducts(completion: @escaping () -> Void = {}) {
        isLoading = true
        errorMessage = nil
        
        let url = APIConstants.Endpoints.products
        networkService.request(url: url, method: .get, body: Optional<ProductCreationRequest>.none) { [weak self] (result: Result<[Product], Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let products):
                    self?.products = products
                    completion()
                case .failure(let error):
                    self?.errorMessage = "Failed to load products: \(error.localizedDescription)"
                    completion()
                }
            }
        }
    }
    
    // Create a new product
    func createProduct(completion: @escaping (Bool) -> Void) {
        guard validateInputs() else {
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Convert string inputs to appropriate types
        guard let priceValue = Double(price),
              let stockValue = Int(stock) else {
            errorMessage = "Invalid price or stock value"
            isLoading = false
            completion(false)
            return
        }
        
        let productRequest = ProductCreationRequest(
            name: name,
            description: description,
            price: priceValue,
            category: category,
            stock: stockValue,
            imageUrl: imageUrl
        )
        
        let url = APIConstants.Endpoints.products
        networkService.request(url: url, method: .post, body: productRequest) { [weak self] (result: Result<Product, Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(_):
                    self?.resetForm()
                    self?.showSuccessAlert = true
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to create product: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    // Delete a product
    func deleteProduct(productId: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let url = "\(APIConstants.Endpoints.products)/\(productId)"
        
        // Define an empty struct for the response
        struct EmptyResponse: Codable {}
        
        networkService.request(url: url, method: .delete, body: Optional<EmptyResponse>.none) { [weak self] (result: Result<EmptyResponse, Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(_):
                    // Remove the product from the local array
                    self?.products.removeAll { $0.id == productId }
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to delete product: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    // Validate all inputs before submission
    private func validateInputs() -> Bool {
        if name.isEmpty {
            errorMessage = "Product name is required"
            return false
        }
        
        if description.isEmpty {
            errorMessage = "Product description is required"
            return false
        }
        
        if price.isEmpty || Double(price) == nil {
            errorMessage = "Valid price is required"
            return false
        }
        
        if category.isEmpty {
            errorMessage = "Category is required"
            return false
        }
        
        if stock.isEmpty || Int(stock) == nil {
            errorMessage = "Valid stock quantity is required"
            return false
        }
        
        if imageUrl.isEmpty {
            errorMessage = "Image URL is required"
            return false
        }
        
        return true
    }
    
    // Reset form after successful submission
    private func resetForm() {
        name = ""
        description = ""
        price = ""
        category = ""
        stock = ""
        imageUrl = ""
    }
} 