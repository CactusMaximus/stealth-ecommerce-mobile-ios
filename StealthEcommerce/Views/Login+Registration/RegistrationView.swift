//
//  RegistrationView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct RegistrationView: View {
    
    @StateObject private var viewModel = UserViewModel()
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var showError = false
    @State private var navigateToLogin = false
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // Validation states
    @State private var usernameError: String = ""
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    @State private var confirmPasswordError: String = ""
    @State private var isValidating: Bool = false
    @State private var refreshToggle: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Language selector at the very top right
                HStack {
                    Spacer()
                    RegionSelectorView()
                }
                .padding(.top, 8)
                .padding(.trailing, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Title below the selector
                        Text("registration.title".localized)
                            .font(.title)
                            .fontWeight(.medium)
                            .padding(.top)
                            .frame(maxWidth: .infinity, alignment: .center)
                    
                        // Username field
                        Text("registration.username.label".localized)
                            .font(.subheadline)
                            .bold()
                        
                        TextField.localized("registration.username.placeholder", text: $username)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(14)
                            .onChange(of: username) { _ in
                                if isValidating {
                                    validateUsername()
                                }
                            }
                        
                        ValidationMessageView(message: usernameError)
                        
                        // Email field
                        Text("registration.email.label".localized)
                            .font(.subheadline)
                            .bold()
                        
                        TextField.localized("registration.email.placeholder", text: $email)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(14)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .onChange(of: email) { _ in
                                if isValidating {
                                    validateEmail()
                                }
                            }
                        
                        ValidationMessageView(message: emailError)
                        
                        // Password field
                        Text("registration.password.label".localized)
                            .font(.subheadline)
                            .bold()
                        
                        SecureField.localized("registration.password.placeholder", text: $password)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(14)
                            .onChange(of: password) { _ in
                                if isValidating {
                                    validatePassword()
                                    if !confirmPassword.isEmpty {
                                        validateConfirmPassword()
                                    }
                                }
                            }
                        
                        ValidationMessageView(message: passwordError)
                        
                        // Confirm Password field
                        Text("registration.confirmPassword.label".localized)
                            .font(.subheadline)
                            .bold()
                        
                        SecureField.localized("registration.confirmPassword.placeholder", text: $confirmPassword)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(14)
                            .onChange(of: confirmPassword) { _ in
                                if isValidating {
                                    validateConfirmPassword()
                                }
                            }
                        
                        ValidationMessageView(message: confirmPasswordError)
                        
                        if showError {
                            Text("registration.error.general".localized)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        Button(action: handleSignup) {
                            Text("registration.button.signup".localized)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(50)
                        }
                        .padding(.top, 10)
                        
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("registration.button.login".localized)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))) { _ in
            // Force refresh by toggling state
            refreshToggle.toggle()
        }
        .id(refreshToggle) // Force view recreation when this changes
        .onChange(of: viewModel.message) { message in
            if message == "Success" {
                navigateToLogin = true
                // Track successful registration
                AnalyticsManager.shared.trackSignUp(method: "email")
            } else if message == "Failure" {
                // Handle registration failure
                if let errorDetails = viewModel.errorDetails {
                    if errorDetails.contains("duplicate") {
                        emailError = "Email already in use. Please use a different email or try logging in."
                    } else {
                        showError = true
                    }
                }
            }
        }
        .trackScreenView(screenName: "Registration")
    }
    
    // Validation functions
    func validateUsername() -> Bool {
        if username.isEmpty {
            usernameError = "registration.username.error.empty".localized
            return false
        }
        
        if username.count < 3 {
            usernameError = "registration.username.error.tooShort".localized
            return false
        }
        
        usernameError = ""
        return true
    }
    
    func validateEmail() -> Bool {
        if email.isEmpty {
            emailError = "registration.email.error.empty".localized
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            emailError = "registration.email.error.invalid".localized
            return false
        }
        
        emailError = ""
        return true
    }
    
    func validatePassword() -> Bool {
        if password.isEmpty {
            passwordError = "registration.password.error.empty".localized
            return false
        }
        
        if password.count < 6 {
            passwordError = "registration.password.error.tooShort".localized
            return false
        }
        
        passwordError = ""
        return true
    }
    
    func validateConfirmPassword() -> Bool {
        if confirmPassword.isEmpty {
            confirmPasswordError = "registration.confirmPassword.error.empty".localized
            return false
        }
        
        if confirmPassword != password {
            confirmPasswordError = "registration.confirmPassword.error.mismatch".localized
            return false
        }
        
        confirmPasswordError = ""
        return true
    }
    
    func handleSignup() {
        isValidating = true
        
        let isUsernameValid = validateUsername()
        let isEmailValid = validateEmail()
        let isPasswordValid = validatePassword()
        let isConfirmPasswordValid = validateConfirmPassword()
        
        if !isUsernameValid || !isEmailValid || !isPasswordValid || !isConfirmPasswordValid {
            showError = true
            return
        }
        
        showError = false
        
        viewModel.createUser(user: User(
            email: email,
            password: password,
            firstName: username,
            lastName: "test3",
            address: Address(street: "test3", city: "test3", state: "test3", zipCode: "test3")
        ))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let message = viewModel.message {
                if message.contains("Success") {
                    navigateToLogin = true
                } else {
                    showError = true
                    if let errorDetails = viewModel.errorDetails, errorDetails.contains("duplicate") {
                        emailError = "registration.email.error.duplicate".localized
                    }
                    debugPrint("Failure")
                }
            }
        }
    }
}

#Preview {
    RegistrationView()
}
