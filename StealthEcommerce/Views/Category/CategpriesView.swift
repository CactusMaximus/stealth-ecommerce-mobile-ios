//
//  CategpriesView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct CategpriesView: View {
    @State private var search: String = ""
    @State private var showCart: Bool = false
    @EnvironmentObject private var cartViewModel: CartViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var refreshToggle: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("browse.search".localized, text: $search)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                    }
                    
                    HeroView()
                    
                    Text("categories.title".localized).font(.title).bold().padding(.top, 10)
                    VStack(alignment: .leading, spacing: 32) {
                        HStack(spacing: 12) {
                            NavigationLink(destination: BrowseView()) {
                                CategoryView(title: "Tools")
                            }
                            NavigationLink(destination: BrowseView()) {
                                CategoryView(title: "Armor")
                            }
                        }
                        HStack(spacing: 12) {
                            NavigationLink(destination: BrowseView()) {
                                CategoryView(title: "Resources")
                            }
                            NavigationLink(destination: BrowseView()) {
                                CategoryView(title: "Food")
                            }
                        }
                    }
                    Spacer()
                    
                }
                .padding(.horizontal)
            }
            .navigationDestination(isPresented: $showCart) {
                CartView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCart = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                            
                            if !cartViewModel.items.isEmpty {
                                Text("\(cartViewModel.items.count)")
                                    .font(.caption2)
                                    .padding(5)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                                    .accessibilityLabel("cart.item_count".localized(with: cartViewModel.items.count))
                            }
                        }
                    }
                    .accessibilityLabel("tab.cart".localized)
                }
            }
            .navigationTitle("BlockMart")
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))) { _ in
                // Force refresh by toggling state
                refreshToggle.toggle()
            }
            .id(refreshToggle) // Force view recreation when language changes
        }
    }
}

#Preview {
    CategpriesView()
        .environmentObject(CartViewModel())
        .environmentObject(LocalizationManager.shared)
}
