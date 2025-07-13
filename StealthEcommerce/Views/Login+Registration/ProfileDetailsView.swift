//
//  ProfileDetailsView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/13.
//

import SwiftUI
import Foundation

struct ProfileDetailsView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var isEditing = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    if let user = userViewModel.currentUser {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Loading profile...")
                            .font(.title)
                            .fontWeight(.bold)
                            .redacted(reason: .placeholder)
                    }
                }
                .padding(.bottom, 20)
                
                // Content based on mode (view or edit)
                if isEditing {
                    editProfileForm
                } else {
                    profileDetailsCard
                }
            }
            .padding()
            .navigationTitle("Profile Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveProfile()
                        } else {
                            isEditing = true
                        }
                    }
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isEditing = false
                            // Reset form data to current user values
                            userViewModel.loadUserDataToForm()
                        }
                    }
                }
            }
            .overlay {
                if userViewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .alert("Profile Updated", isPresented: $showingSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("Your profile has been successfully updated.")
            }
            .alert("Update Failed", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(userViewModel.errorDetails ?? "An unknown error occurred.")
            }
        }
        .onAppear {
            // If we have user data, load it into the form
            if let user = userViewModel.currentUser {
                userViewModel.loadUserDataToForm()
            }
        }
    }
    
    private var profileDetailsCard: some View {
        VStack(spacing: 20) {
            // Personal Information Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Personal Information")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                if let user = userViewModel.currentUser {
                    HStack {
                        Text("First Name:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.firstName)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Last Name:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.lastName)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Email:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.email)
                    }
                } else {
                    Text("Loading user details...")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Address Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Address")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                if let user = userViewModel.currentUser {
                    HStack {
                        Text("Street:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.address.street)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("City:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.address.city)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("State:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.address.state)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Zip Code:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.address.zipCode)
                    }
                } else {
                    Text("Loading address details...")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Account Information Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Account Information")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                if let user = userViewModel.currentUser {
                    HStack {
                        Text("Account ID:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.id)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Member Since:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(formatDate(user.createdAt))
                    }
                } else {
                    Text("Loading account details...")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var editProfileForm: some View {
        VStack(spacing: 20) {
            // Personal Information Form
            VStack(alignment: .leading, spacing: 15) {
                Text("Personal Information")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                TextField("First Name", text: $userViewModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("Last Name", text: $userViewModel.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("Email", text: $userViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Address Form
            VStack(alignment: .leading, spacing: 15) {
                Text("Address")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                TextField("Street", text: $userViewModel.street)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("City", text: $userViewModel.city)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("State", text: $userViewModel.state)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Zip Code", text: $userViewModel.zipCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private func saveProfile() {
        guard let currentUser = userViewModel.currentUser else {
            return
        }
        
        print("📝 Attempting to update profile for user ID: \(currentUser.id)")
        
        // Call the API to update the user profile
        userViewModel.updateUserProfile(userId: currentUser.id) { success in
            print("📝 Profile update result: \(success ? "Success" : "Failure")")
            if success {
                isEditing = false
                showingSuccessAlert = true
            } else {
                showingErrorAlert = true
                print("❌ Update error: \(self.userViewModel.errorDetails ?? "Unknown error")")
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        ProfileDetailsView()
            .environmentObject(UserViewModel())
    }
} 