//
//  UserViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation

class UserViewModel: ObservableObject {
    
    @Published var message: String?
    @Published var errorDetails: String?
    @Published var currentUser: UserResponse?
    @Published var isAdmin: Bool = false // Add isAdmin property
    
    private var networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService.shared) {
        self.networkService = networkService
        
        // For testing purposes, set isAdmin to true
        // In a real app, this would be determined by the user's role from the API
        #if DEBUG
        isAdmin = true
        #endif
    }
    
    //POST User - Create a user
    func createUser(user: User) {
        networkService.request(url: APIConstants.Endpoints.users, method: .post, body: user) { [weak self] (result: Result<UserResponse, Error>) in
            
            switch result {
               case .success(let user):
                DispatchQueue.main.async {
                    self?.message = "Success"
                    self?.currentUser = user
                    // In a real app, you would check if the user has admin role
                    // self?.isAdmin = user.isAdmin
                }
                print("✅ Registered user:", user)
               case .failure(let error):
                DispatchQueue.main.async {
                    self?.message = "Failure"
                    self?.errorDetails = error.localizedDescription
                }
                print("❌ Registration error:", error)
               }
        }
    }
    
    //POST User - Login user
    func loginUser(email: String, password: String) {
        // Create a login request with just email and password
        let loginRequest = LoginRequest(email: email, password: password)
        
        networkService.request(url: APIConstants.Endpoints.login, method: .post, body: loginRequest) { [weak self] (result: Result<UserResponse, Error>) in
            
            switch result {
               case .success(let user):
                DispatchQueue.main.async {
                    self?.message = "Success"
                    self?.currentUser = user
                    // In a real app, you would check if the user has admin role
                    // self?.isAdmin = user.isAdmin
                }
                print("✅ Logged in user:", user)
               case .failure(let error):
                DispatchQueue.main.async {
                    self?.message = "Failure"
                    self?.errorDetails = error.localizedDescription
                }
                print("❌ Login error:", error)
               }
        }
    }
}
