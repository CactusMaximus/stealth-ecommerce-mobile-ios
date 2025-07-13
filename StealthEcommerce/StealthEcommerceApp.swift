//
//  StealthEcommerceApp.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/09.
//

import SwiftUI

@main
struct StealthEcommerceApp: App {
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var orderViewModel = OrderViewModel()
    
    init() {
        // Print API endpoints for debugging
        APIConstants.printAllEndpoints()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cartViewModel)
                .environmentObject(orderViewModel)
        }
    }
}

struct ContentView: View {
    var body: some View {
        CategpriesView()
    }
}
