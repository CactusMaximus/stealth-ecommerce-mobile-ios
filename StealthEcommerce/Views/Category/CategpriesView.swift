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
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var cartViewModel: CartViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var refreshToggle: Bool = false
    
    // Grid layout for categories
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("home.search".localized, text: $search)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                    }
                    
                    if homeViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        // Hero section
                        HeroView(heroCard: homeViewModel.heroCard)
                            .onTapGesture {
                                // Handle hero card tap if needed
                            }
                        
                        // Categories section
                        Text("home.categories".localized)
                            .font(.title)
                            .bold()
                            .padding(.top, 10)
                        
                        if homeViewModel.categories.isEmpty {
                            Text("home.no_categories".localized)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            // Grid layout for categories
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(homeViewModel.categories) { category in
                                    NavigationLink(destination: BrowseView(selectedCategory: category.id)) {
                                        CategoryView(category: category)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let error = homeViewModel.errorMessage {
                        VStack {
                            Text("home.error.loading".localized)
                                .foregroundColor(.red)
                                .padding()
                            
                            Button("home.retry".localized) {
                                homeViewModel.fetchHomeData()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
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
            .navigationTitle("home.title".localized)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))) { _ in
                // Force refresh by toggling state
                refreshToggle.toggle()
            }
            .id(refreshToggle) // Force view recreation when language changes
            .onAppear {
                homeViewModel.fetchHomeData()
            }
            .refreshable {
                homeViewModel.fetchHomeData()
            }
        }
    }
}

#Preview {
    CategpriesView()
        .environmentObject(CartViewModel())
        .environmentObject(LocalizationManager.shared)
        .environmentObject(HomeViewModel())
}
