//
//  StealthEcommerceApp.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/09.
//

import SwiftUI

@main
struct StealthEcommerceApp: App {
    @State private var showRestartPrompt = false
    @State private var selectedLanguageName = ""
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var cartViewModel = CartViewModel()
    @State private var refreshToggle = false
    
    init() {
        // Initialize localization is now handled by LocalizationManager
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                RegistrationView()
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))) { _ in
                        // Force refresh by toggling state
                        refreshToggle.toggle()
                    }
                    .environmentObject(localizationManager)
                    .environmentObject(cartViewModel)
                    .id(refreshToggle) // Force view recreation when this changes
                
                // Show restart prompt if needed
                if showRestartPrompt {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            // Do nothing, prevent taps from going through
                        }
                    
                    RestartAppView(isPresented: $showRestartPrompt, languageName: selectedLanguageName)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(20)
                        .transition(.scale)
                        .animation(.easeInOut, value: showRestartPrompt)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowRestartPrompt"))) { notification in
                if let languageName = notification.userInfo?["languageName"] as? String {
                    selectedLanguageName = languageName
                    showRestartPrompt = true
                }
            }
        }
    }
}
