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
    @EnvironmentObject private var localizationManager: LocalizationManager
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
                        Text("profile_details.loading".localized)
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
            .navigationTitle("profile_details.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "profile_details.save".localized : "profile_details.edit".localized) {
                        if isEditing {
                            saveProfile()
                        } else {
                            isEditing = true
                        }
                    }
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("profile_details.cancel".localized) {
                            isEditing = false
                            // Reset form data to current user values
                            userViewModel.loadUserDataToForm()
                        }
                    }
                }
            }
            .overlay {
                if userViewModel.isLoading {
                    ProgressView("common.loading".localized)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .alert("profile_details.alert.updated".localized, isPresented: $showingSuccessAlert) {
                Button("common.ok".localized) { }
            } message: {
                Text("profile_details.alert.updated_message".localized)
            }
            .alert("profile_details.alert.failed".localized, isPresented: $showingErrorAlert) {
                Button("common.ok".localized) { }
            } message: {
                Text(userViewModel.errorDetails ?? "profile_details.alert.unknown_error".localized)
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
                Text("profile_details.personal_info".localized)
                    .font(.headline)
                    .padding(.bottom, 5)
                
                if let user = userViewModel.currentUser {
                    HStack {
                        Text("profile_details.first_name".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.firstName)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("profile_details.last_name".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.lastName)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("profile_details.email".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.email)
                    }
                } else {
                    Text("profile_details.loading_user".localized)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Address Section
            VStack(alignment: .leading, spacing: 15) {
                Text("profile_details.address".localized)
                    .font(.headline)
                    .padding(.bottom, 5)
                
                if let user = userViewModel.currentUser {
                    HStack {
                        Text("profile_details.street".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.address.street)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("profile_details.city".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.address.city)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("profile_details.state".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.address.state)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("profile_details.zip_code".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.address.zipCode)
                    }
                } else {
                    Text("profile_details.loading_address".localized)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Account Information Section
            VStack(alignment: .leading, spacing: 15) {
                Text("profile_details.account_info".localized)
                    .font(.headline)
                    .padding(.bottom, 5)
                
                if let user = userViewModel.currentUser {
                    HStack {
                        Text("profile_details.account_id".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(user.id)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("profile_details.member_since".localized)
                            .fontWeight(.medium)
                        Spacer()
                        Text(formatDate(user.createdAt))
                    }
                } else {
                    Text("profile_details.loading_account".localized)
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
                Text("profile_details.personal_info".localized)
                    .font(.headline)
                    .padding(.bottom, 5)
                
                TextField("profile_details.first_name".localized, text: $userViewModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("profile_details.last_name".localized, text: $userViewModel.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("profile_details.email".localized, text: $userViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Address Form
            VStack(alignment: .leading, spacing: 15) {
                Text("profile_details.address".localized)
                    .font(.headline)
                    .padding(.bottom, 5)
                
                TextField("profile_details.street".localized, text: $userViewModel.street)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("profile_details.city".localized, text: $userViewModel.city)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("profile_details.state".localized, text: $userViewModel.state)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("profile_details.zip_code".localized, text: $userViewModel.zipCode)
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
        dateFormatter.locale = Locale.current
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        ProfileDetailsView()
            .environmentObject(UserViewModel())
            .environmentObject(LocalizationManager.shared)
    }
} 