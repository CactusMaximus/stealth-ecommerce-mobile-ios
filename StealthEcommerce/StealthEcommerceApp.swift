//
//  StealthEcommerceApp.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/09.
//

import SwiftUI
import UIKit
import FirebaseCore
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Enable Analytics data collection if available
        #if canImport(FirebaseAnalytics)
        Analytics.setAnalyticsCollectionEnabled(true)
        print("✅ Firebase Analytics configured")
        #endif
        
        // App initialization
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle Google Sign-In callback
        return GoogleSignInManager.shared.handleSignInCallback(url: url)
    }
}

@main
struct StealthEcommerceApp: App {
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    
    // Register app delegate for handling URL callbacks
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Print API endpoints for debugging
        APIConstants.printAllEndpoints()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cartViewModel)
                .environmentObject(orderViewModel)
                .environmentObject(userViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(LocalizationManager.shared)
                .onOpenURL { url in
                    // Handle Google Sign-In callback
                    _ = GoogleSignInManager.shared.handleSignInCallback(url: url)
                }
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var refreshToggle: Bool = false
    
    var body: some View {
        if userViewModel.currentUser == nil {
            LoginView()
                .environmentObject(userViewModel)
        } else {
            TabView(selection: $selectedTab) {
                // Home tab
                CategpriesView()
                    .tabItem {
                        Label("tab.home".localized, systemImage: "house")
                    }
                    .tag(0)
                
                // Browse tab
                BrowseView()
                    .tabItem {
                        Label("tab.browse".localized, systemImage: "magnifyingglass")
                    }
                    .tag(1)
                
                // Shop tab (with cart icon)
                CartView()
                    .tabItem {
                        Label("tab.cart".localized, systemImage: "cart")
                    }
                    .tag(2)
                
                // Admin-only product management tab
                if userViewModel.isAdmin {
                    ProductManagementView()
                        .tabItem {
                            Label("tab.manage".localized, systemImage: "square.and.pencil")
                        }
                        .tag(3)
                }
                
                // Profile tab
                ProfileView()
                    .tabItem {
                        Label("tab.profile".localized, systemImage: "person")
                    }
                    .tag(4)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))) { _ in
                // Force refresh by toggling state
                refreshToggle.toggle()
            }
            .id(refreshToggle) // Force view recreation when language changes
        }
    }
}
