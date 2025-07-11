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
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var loginMessage: String?
    @State private var goToHome: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Username")
                    .font(.subheadline)
                    .bold()
                    .padding(.top)
                
                // Username Field
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                    .autocapitalization(.none)
                
                // Password Field
                Text("Password")
                    .font(.subheadline)
                    .bold()
                    .padding(.top)
                
                HStack {
                    Group {
                        if showPassword {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                    }
                    .padding()
                    .autocapitalization(.none)
                    
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
                
                if let message = loginMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .padding(.top)
                    //                    DispatchQueue.main.async {
                    
                    //                    }
                }
                
                Button(action: handleLogin) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(50)
                }
                
                Spacer()
            }
            
            .padding()
            .navigationDestination(isPresented: $goToHome) {CategpriesView()}
        }
    }
    
    func handleLogin() {
        if username.isEmpty || password.isEmpty {
            loginMessage = "Please enter both username and password."
        } else {
            
            viewModel.loginUser(user: User(email: username, password: password, firstName: username, lastName: username, address: Address(street: "test", city: "test", state: "test", zipCode: "test")))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let message = viewModel.message {
                    debugPrint(message)
                    if !message.contains("Invalid") {
                        goToHome = true
                    } else {
                        loginMessage = "Invalid details"
                    }
                }
            }
            
        }
    }
}

#Preview {
    LoginView()
}
