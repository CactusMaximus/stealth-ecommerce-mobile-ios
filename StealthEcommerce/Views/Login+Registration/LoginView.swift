//
//  ContentView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/09.
//

import Foundation
import SwiftUI

struct LoginView: View {
    
    @StateObject private var viewModel = UserViewModel()
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var loginMessage: String?
    @State private var goToHome: Bool = false
    @State private var goToRegistration: Bool = false
    
    // Validation states
    @State private var usernameError: String = ""
    @State private var passwordError: String = ""
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
                
                    Text("login.username.label".localized)
                        .font(.subheadline)
                        .bold()
                        .padding(.top)
                
                    // Username Field
                    TextField.localized("login.username.placeholder", text: $username)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(14)
                        .autocapitalization(.none)
                        .onChange(of: username) { _ in
                            if isValidating {
                                validateUsername()
                            }
                        }
                    
                    ValidationMessageView(message: usernameError)
                    
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
    }
    
    func validateUsername() -> Bool {
        if username.isEmpty {
            usernameError = "Username cannot be empty"
            return false
        }
        
        usernameError = ""
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
        
        let isUsernameValid = validateUsername()
        let isPasswordValid = validatePassword()
        
        if !isUsernameValid || !isPasswordValid {
            return
        }
        
        viewModel.loginUser(user: User(email: username, password: password, firstName: username, lastName: username, address: Address(street: "test", city: "test", state: "test", zipCode: "test")))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let message = viewModel.message {
                debugPrint(message)
                if message.contains("Success") {
                    goToHome = true
                } else {
                    if let errorDetails = viewModel.errorDetails {
                        loginMessage = "Login failed: \(errorDetails)"
                    } else {
                        loginMessage = "Invalid username or password"
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
