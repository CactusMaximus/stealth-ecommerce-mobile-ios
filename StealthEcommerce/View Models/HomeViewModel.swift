//
//  HomeViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var heroCard: HeroCard?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchHomeData() {
        isLoading = true
        errorMessage = nil
        
        let url = APIConstants.Endpoints.home
        
        NetworkService.shared.request(url: url, method: .get, body: Optional<String>.none) { (result: Result<HomeScreenData, Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let data):
                    self.categories = data.categories
                    self.heroCard = data.heroCard
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Error fetching home data: \(error)")
                    
                    // Load mock data as fallback
                    self.loadMockData()
                }
            }
        }
    }
    
    func loadMockData() {
        // Mock categories
        self.categories = [
            Category(id: "tools", name: "Tools", imageUrl: "tools"),
            Category(id: "armor", name: "Armor", imageUrl: "tools"),
            Category(id: "resources", name: "Resources", imageUrl: "tools"),
            Category(id: "food", name: "Food", imageUrl: "tools"),
            Category(id: "electronics", name: "Electronics", imageUrl: "tools"),
            Category(id: "clothing", name: "Clothing", imageUrl: "tools")
        ]
        
        // Mock hero card
        self.heroCard = HeroCard(
            title: "Featured Items",
            imageUrl: "hero",
            linkTo: "/featured"
        )
    }
} 