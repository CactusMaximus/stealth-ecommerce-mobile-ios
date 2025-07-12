//
//  LocalizationManager.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation
import SwiftUI
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Get current language from UserDefaults
        if let languageCode = UserDefaults.standard.string(forKey: "AppleLanguages") {
            let cleanCode = languageCode.trimmingCharacters(in: CharacterSet(charactersIn: "[]\""))
            self.currentLanguage = cleanCode
        } else {
            // Default to device language
            self.currentLanguage = Locale.preferredLanguages.first ?? "en"
        }
        
        // Apply initial language
        self.applyLanguage(self.currentLanguage)
        
        // Listen for language changes
        NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))
            .sink { [weak self] _ in
                if let languageCode = UserDefaults.standard.string(forKey: "AppleLanguages") {
                    let cleanCode = languageCode.trimmingCharacters(in: CharacterSet(charactersIn: "[]\""))
                    self?.currentLanguage = cleanCode
                    self?.applyLanguage(cleanCode)
                }
            }
            .store(in: &cancellables)
    }
    
    func applyLanguage(_ languageCode: String) {
        // Update the Bundle for localization
        Bundle.setLanguage(languageCode)
        
        // Force UI to update by publishing changes
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
} 