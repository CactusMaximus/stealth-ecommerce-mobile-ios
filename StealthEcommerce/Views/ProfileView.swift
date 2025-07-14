//
//  ProfileView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct ProfileView: View {
    // Hardcoded user ID for demo purposes - in a real app, this would come from user authentication
    let userId = "65f5a1d2e1b7c2a3d4f5e6a7" // Use a real ID from your database that exists in MongoDB
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showingLogoutAlert = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var showLanguageSelector = false
    @ObservedObject private var regionManager = RegionManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("profile.section.account".localized)) {
                        NavigationLink(destination: ProfileDetailsView()) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.yellow)
                                Text("profile.account.settings".localized)
                            }
                        }
                        
                        NavigationLink(destination: Text("Payment Methods")) {
                            HStack {
                                Image(systemName: "creditcard")
                                    .foregroundColor(.yellow)
                                Text("profile.payment.methods".localized)
                            }
                        }
                    }
                    
                    Section(header: Text("profile.section.orders".localized)) {
                        NavigationLink(destination: OrderHistoryView(userId: userId)) {
                            HStack {
                                Image(systemName: "bag")
                                    .foregroundColor(.yellow)
                                Text("profile.order.history".localized)
                            }
                        }
                        
                        NavigationLink(destination: Text("Saved Items")) {
                            HStack {
                                Image(systemName: "heart")
                                    .foregroundColor(.yellow)
                                Text("profile.saved.items".localized)
                            }
                        }
                    }
                    
                    Section(header: Text("profile.section.preferences".localized)) {
                        Button(action: {
                            showLanguageSelector = true
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.yellow)
                                Text("profile.language".localized)
                                Spacer()
                                Text(regionManager.currentRegion.flag + " " + regionManager.currentRegion.displayName)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section(header: Text("profile.section.support".localized)) {
                        NavigationLink(destination: Text("Help Center")) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.yellow)
                                Text("profile.help.center".localized)
                            }
                        }
                        
                        NavigationLink(destination: Text("Contact Us")) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.yellow)
                                Text("profile.contact.us".localized)
                            }
                        }
                    }
                    
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("profile.logout".localized)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("profile.title".localized)
                .alert("profile.logout".localized, isPresented: $showingLogoutAlert) {
                    Button("common.cancel".localized, role: .cancel) { }
                    Button("profile.logout".localized, role: .destructive) {
                        logout()
                    }
                } message: {
                    Text("profile.logout.confirmation".localized)
                }
                .alert("common.error".localized, isPresented: $showError) {
                    Button("common.ok".localized, role: .cancel) { }
                } message: {
                    Text(userViewModel.errorDetails ?? "profile.error.loading".localized)
                }
                
                if isLoading {
                    ProgressView("profile.loading".localized)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .sheet(isPresented: $showLanguageSelector) {
                languageSelectorView
            }
        }
        .onAppear {
            fetchUserData()
        }
    }
    
    private var languageSelectorView: some View {
        NavigationView {
            List {
                ForEach(USRegion.allCases) { region in
                    Button(action: {
                        regionManager.setRegion(region)
                        showLanguageSelector = false
                    }) {
                        HStack {
                            LanguageFlagView(
                                region: region,
                                isSelected: regionManager.currentRegion == region
                            )
                            Spacer()
                            if regionManager.currentRegion == region {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("profile.language.selection".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.done".localized) {
                        showLanguageSelector = false
                    }
                }
            }
        }
    }
    
    private func fetchUserData() {
        isLoading = true
        
        // Try to fetch from API
        userViewModel.fetchUserDetails(userId: userId)
        
        // Add a timeout to fall back to mock data if API call fails
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isLoading = false
            
            // If API call failed or we didn't get data, use mock data
            if userViewModel.currentUser == nil {
                if userViewModel.errorDetails != nil {
                    showError = true
                }
                simulateLoggedInUser()
            }
        }
    }
    
    private func logout() {
        // Use the UserViewModel's logout method instead of manually clearing data
        userViewModel.logout()
    }
    
    // For demo purposes only - in a real app, this would be handled by proper authentication
    private func simulateLoggedInUser() {
        let demoAddress = Address(
            street: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94105"
        )
        
        let demoUser = UserResponse(
            email: "demo@example.com",
            firstName: "John",
            lastName: "Doe",
            address: demoAddress,
            _id: userId, // Use the same userId defined at the top of the view
            createdAt: "2025-07-01T12:00:00.000Z",
            updatedAt: "2025-07-01T12:00:00.000Z",
            __v: 0
        )
        
        userViewModel.currentUser = demoUser
        userViewModel.loadUserDataToForm()
        
        // Save the demo user to session storage
        UserSessionManager.shared.saveUserSession(demoUser)
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserViewModel())
        .environmentObject(LocalizationManager.shared)
}
