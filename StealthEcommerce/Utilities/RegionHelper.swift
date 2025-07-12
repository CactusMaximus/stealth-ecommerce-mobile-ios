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
        LocalizationManager.shared.applyLanguage(region.rawValue)
        
        // Post notification for views to refresh
        NotificationCenter.default.post(name: NSNotification.Name("RegionChanged"), object: nil)
        
        // Post notification for restart prompt
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowRestartPrompt"),
            object: nil,
            userInfo: ["languageName": region.displayName]
        )
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

// SwiftUI View for region selection
struct RegionSelectorView: View {
    @ObservedObject private var regionManager = RegionManager.shared
    @State private var isExpanded = false
    @State private var selectedRegion: USRegion
    @State private var refreshToggle = false
    
    init() {
        _selectedRegion = State(initialValue: RegionManager.shared.currentRegion)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Current selected language button
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                // More compact flag view for the main button
                Text(regionManager.currentRegion.flag)
                    .font(.title2)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 2)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Dropdown menu
            if isExpanded {
                VStack(alignment: .trailing, spacing: 4) {
                    // Add spacing to push dropdown below the button
                    Spacer().frame(height: 36)
                    
                    // Dropdown background with languages
                    VStack(alignment: .trailing, spacing: 2) {
                        ForEach(USRegion.allCases.filter { $0 != regionManager.currentRegion }) { region in
                            Button(action: {
                                withAnimation(.spring()) {
                                    isExpanded = false
                                    selectedRegion = region
                                    regionManager.setRegion(region)
                                }
                            }) {
                                LanguageFlagView(
                                    region: region,
                                    isSelected: false
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                    )
                }
                .zIndex(100)
                .transition(.opacity)
            }
        }
        .onChange(of: selectedRegion) { _ in
            // Force refresh by toggling state
            refreshToggle.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))) { _ in
            // Force refresh by toggling state
            refreshToggle.toggle()
        }
        // Close dropdown when tapping elsewhere
        .onTapGesture {
            if isExpanded {
                withAnimation(.spring()) {
                    isExpanded = false
                }
            }
        }
        .id(refreshToggle) // Force view recreation when this changes
    }
} 