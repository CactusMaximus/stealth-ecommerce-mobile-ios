//
//  LocalizationManager.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "app_language")
            updateLocale()
        }
    }
    
    private init() {
        // Get the saved language or use the system language
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language") {
            self.currentLanguage = savedLanguage
        } else {
            // Get the preferred language from the system
            if let preferredLanguage = Locale.preferredLanguages.first {
                self.currentLanguage = preferredLanguage
            } else {
                self.currentLanguage = "en" // Default to English
            }
        }
        
        updateLocale()
    }
    
    private func updateLocale() {
        // Update the app's locale based on the selected language
        UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    // Change the app's language
    func setLanguage(_ language: String) {
        currentLanguage = language
        NotificationCenter.default.post(name: NSNotification.Name("RegionChanged"), object: nil)
    }
} 