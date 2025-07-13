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
    @State private var showingLogoutAlert = false
    @State private var isLoading = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("ACCOUNT")) {
                        NavigationLink(destination: ProfileDetailsView()) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.yellow)
                                Text("Account Settings")
                            }
                        }
                        
                        NavigationLink(destination: Text("Payment Methods")) {
                            HStack {
                                Image(systemName: "creditcard")
                                    .foregroundColor(.yellow)
                                Text("Payment Methods")
                            }
                        }
                    }
                    
                    Section(header: Text("ORDERS")) {
                        NavigationLink(destination: OrderHistoryView(userId: userId)) {
                            HStack {
                                Image(systemName: "bag")
                                    .foregroundColor(.yellow)
                                Text("Order History")
                            }
                        }
                        
                        NavigationLink(destination: Text("Saved Items")) {
                            HStack {
                                Image(systemName: "heart")
                                    .foregroundColor(.yellow)
                                Text("Saved Items")
                            }
                        }
                    }
                    
                    Section(header: Text("SUPPORT")) {
                        NavigationLink(destination: Text("Help Center")) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.yellow)
                                Text("Help Center")
                            }
                        }
                        
                        NavigationLink(destination: Text("Contact Us")) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.yellow)
                                Text("Contact Us")
                            }
                        }
                    }
                    
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Logout")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Profile")
                .alert("Logout", isPresented: $showingLogoutAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Logout", role: .destructive) {
                        logout()
                    }
                } message: {
                    Text("Are you sure you want to logout?")
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(userViewModel.errorDetails ?? "Failed to load user data")
                }
                
                if isLoading {
                    ProgressView("Loading profile...")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        }
        .onAppear {
            fetchUserData()
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
        // Clear user data
        print("User logged out")
        
        // Clear the current user data
        userViewModel.currentUser = nil
        
        // Reset form data
        userViewModel.firstName = ""
        userViewModel.lastName = ""
        userViewModel.email = ""
        userViewModel.street = ""
        userViewModel.city = ""
        userViewModel.state = ""
        userViewModel.zipCode = ""
        
        // Clear any error messages
        userViewModel.errorDetails = nil
        userViewModel.message = nil
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
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserViewModel())
}
