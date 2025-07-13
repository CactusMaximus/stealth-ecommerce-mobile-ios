//
//  RegionHelper.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation
import SwiftUI

// Supported regions
enum USRegion: String, CaseIterable, Identifiable {
    case general = "en"      // Default/General US
    case american = "en-US"  // American English
    case british = "en-GB"   // British English
    case canadian = "en-CA"  // Canadian English
    case spanish = "es"      // Spanish
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .general:
            return "English (Default)"
        case .american:
            return "English (US)"
        case .british:
            return "English (UK)"
        case .canadian:
            return "English (Canada)"
        case .spanish:
            return "Spanish"
        }
    }
    
    var flag: String {
        switch self {
        case .general:
            return "🇺🇸"
        case .american:
            return "🇺🇸"
        case .british:
            return "🇬🇧"
        case .canadian:
            return "🇨🇦"
        case .spanish:
            return "🇪🇸"
        }
    }
    
    var shortName: String {
        switch self {
        case .general:
            return "EN"
        case .american:
            return "EN-US"
        case .british:
            return "EN-GB"
        case .canadian:
            return "EN-CA"
        case .spanish:
            return "ES"
        }
    }
}

class RegionManager: ObservableObject {
    @Published var currentRegion: USRegion
    
    static let shared = RegionManager()
    
    private init() {
        // Get preferred language from device
        if let preferredLanguage = Locale.preferredLanguages.first {
            if let region = USRegion.allCases.first(where: { preferredLanguage.hasPrefix($0.rawValue) }) {
                self.currentRegion = region
                return
            }
        }
        
        // Default to general if no match
        self.currentRegion = .general
    }
    
    func setRegion(_ region: USRegion) {
        self.currentRegion = region
        
        // Store the selected region preference
        UserDefaults.standard.set([region.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Update localization manager
        LocalizationManager.shared.setLanguage(region.rawValue)
        
        // Post notification for views to refresh
        NotificationCenter.default.post(name: NSNotification.Name("RegionChanged"), object: nil)
    }
}

// Extension to Bundle for language switching
extension Bundle {
    private static var bundle: Bundle?
    
    static func setLanguage(_ language: String) {
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        bundle = path != nil ? Bundle(path: path!) : nil
    }
    
    static func localizedBundle() -> Bundle {
        return bundle ?? Bundle.main
    }
} 