//
//  ContentView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/09.
//

import Foundation
import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var viewModel: UserViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var loginMessage: String?
    @State private var goToHome: Bool = false
    @State private var goToRegistration: Bool = false
    
    // Validation states
    @State private var passwordError: String = ""
    @State private var emailError: String = ""
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
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title below the selector
                    Text("login.title".localized)
                        .font(.title)
                        .fontWeight(.medium)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                
                    Text("login.email.label".localized)
                        .font(.subheadline)
                        .bold()
                        .padding(.top)
                    // Email Field
                    TextField.localized("login.email.placeholder", text: $email)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(14)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .onChange(of: email) { _ in
                            if isValidating {
                                validateEmail()
                            }
                        }
                    ValidationMessageView(message: emailError)
                    
                    // Password Field
                    Text("login.password.label".localized)
                        .font(.subheadline)
                        .bold()
                        .padding(.top)
                    
                    HStack {
                        Group {
                            if showPassword {
                                TextField.localized("login.password.placeholder", text: $password)
                            } else {
                                SecureField.localized("login.password.placeholder", text: $password)
                            }
                        }
                        .padding()
                        .autocapitalization(.none)
                        .onChange(of: password) { _ in
                            if isValidating {
                                validatePassword()
                            }
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                    
                    ValidationMessageView(message: passwordError)
                    
                    if let message = loginMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .padding(.top)
                    }
                    
                    Button(action: handleLogin) {
                        Text("login.button.login".localized)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(50)
                    }
                    
                    Button(action: {
                        goToRegistration = true
                    }) {
                        Text("login.button.signup".localized)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                
                .padding()
                .navigationDestination(isPresented: $goToHome) {
                    CategpriesView()
                }
                .navigationDestination(isPresented: $goToRegistration) {
                    RegistrationView()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))) { _ in
            // Force refresh by toggling state
            refreshToggle.toggle()
        }
        .id(refreshToggle) // Force view recreation when this changes
        .onChange(of: viewModel.message) { newValue in
            if newValue == "Success" {
                goToHome = true
            } else if newValue == "Failure" {
                if let errorDetails = viewModel.errorDetails {
                    loginMessage = "Login failed: \(errorDetails)"
                } else {
                    loginMessage = "Invalid email or password"
                }
            }
        }
    }
    
    func validateUsername() -> Bool {
        return true // No longer used
    }
    func validateEmail() -> Bool {
        if email.isEmpty {
            emailError = "Email cannot be empty"
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            emailError = "Invalid email address"
            return false
        }
        emailError = ""
        return true
    }
    
    func validatePassword() -> Bool {
        if password.isEmpty {
            passwordError = "Password cannot be empty"
            return false
        }
        
        passwordError = ""
        return true
    }
    
    func handleLogin() {
        isValidating = true
        loginMessage = nil
        
        let isEmailValid = validateEmail()
        let isPasswordValid = validatePassword()
        if !isEmailValid || !isPasswordValid {
            return
        }
        
        viewModel.loginUser(email: email, password: password)
    }
}

#Preview {
    LoginView()
        .environmentObject(UserViewModel())
}
