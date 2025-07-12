//
//  RegistrationView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct RegistrationView: View {
    
    @StateObject private var viewModel = UserViewModel()
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Create an account")
                        .font(.title)
                        .fontWeight(.medium)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Username field
                    Text("Username")
                        .font(.subheadline)
                        .bold()
                    
                    TextField("Username", text: $username)
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
                    Text("Email")
                        .font(.subheadline)
                        .bold()
                    
                    TextField("Email", text: $email)
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
                    Text("Password")
                        .font(.subheadline)
                        .bold()
                    
                    SecureField("Password", text: $password)
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
                    Text("Confirm Password")
                        .font(.subheadline)
                        .bold()
                    
                    SecureField("Confirm Password", text: $confirmPassword)
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
                        Text("Please correct the errors above")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Button(action: handleSignup) {
                        Text("Sign Up")
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
                        Text("Already have an account? Log in")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
    }
    
    // Validation functions
    func validateUsername() -> Bool {
        if username.isEmpty {
            usernameError = "Username cannot be empty"
            return false
        }
        
        if username.count < 3 {
            usernameError = "Username must be at least 3 characters"
            return false
        }
        
        usernameError = ""
        return true
    }
    
    func validateEmail() -> Bool {
        if email.isEmpty {
            emailError = "Email cannot be empty"
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            emailError = "Please enter a valid email address"
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
        
        if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
            return false
        }
        
        passwordError = ""
        return true
    }
    
    func validateConfirmPassword() -> Bool {
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password"
            return false
        }
        
        if confirmPassword != password {
            confirmPasswordError = "Passwords do not match"
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
                        emailError = "This email is already registered"
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
