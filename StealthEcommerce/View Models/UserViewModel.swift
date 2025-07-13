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
    
    private var networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService.shared) {
        self.networkService = networkService
    }
    
    //POST User - Create a user
    func createUser(user: User) {
        networkService.request(url: APIConstants.Endpoints.users, method: .post, body: user) { [weak self] (result: Result<UserResponse, Error>) in
            
            switch result {
               case .success(let user):
                DispatchQueue.main.async {
                    self?.message = "Success"
                    self?.currentUser = user
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
