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
    
    private var networkService: NetworkService?
    
    init(networkService: NetworkService = NetworkService.shared) {
        self.networkService = networkService
    }
    
    //POST User - Create a user
    func createUser(user: User) {
        networkService?.request(url: "http://localhost:3000/api/users", method: .post, body: user) { (result: Result<UserResponse, Error>) in
            
            switch result {
               case .success(let user):
                DispatchQueue.main.async(execute: {
                    self.message = "Success"
                })
                debugPrint("Registered user:", user)
               case .failure(let error):
                DispatchQueue.main.async(execute: {
                    self.message = "Failure"
                    self.errorDetails = error.localizedDescription
                })
                debugPrint("Registered error:", error)
               }
        }
    }
    
    //POST User - Login user
    func loginUser(user: User) {
        // Create a login request with just email and password
        let loginRequest = LoginRequest(email: user.email, password: user.password)
        
        networkService?.request(url: "http://localhost:3000/api/users/login", method: .post, body: loginRequest) { (result: Result<UserResponse, Error>) in
            
            switch result {
               case .success(let user):
                DispatchQueue.main.async(execute: {
                    self.message = "Success"
                })
                debugPrint("Logged in user:", user)
               case .failure(let error):
                DispatchQueue.main.async(execute: {
                    self.message = "Failure"
                    self.errorDetails = error.localizedDescription
                })
                debugPrint("Login error:", error)
               }
        }
    }
}
