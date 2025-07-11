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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create an account").font(.title).fontWeight(.medium)
                    .padding(.top)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                
                TextField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                
                if showError {
                    Text("Please enter all fields")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
                
                Button(action: handleSignup) {
                    
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(50)
                }
                
                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigateToLogin){
                LoginView()
            }
        }
    }
    
    func handleSignup() {
        if username.isEmpty || password.isEmpty || email.isEmpty {
            showError = true
        } else {
            showError = false
            
            viewModel.createUser(user: User(email: email, password: password, firstName: username, lastName: "test3", address: Address(street: "test3", city: "test3", state: "test3", zipCode: "test3")))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let message = viewModel.message {
                navigateToLogin = true
            }
        }
    }
}


#Preview {
    RegistrationView()
}
