//
//  UserViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation

class UserViewModel: ObservableObject {
    
    @Published var message: String?
    
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
                })
                debugPrint("Registered error:", error.localizedDescription)
               }
        }
    }
    
    //POST User - Login user
    func loginUser(user: User) {
        networkService?.request(url: "http://localhost:3000/api/users/login", method: .post, body: user) { (result: Result<UserResponse, Error>) in
            
            switch result {
               case .success(let user):
                DispatchQueue.main.async(execute: {
                    self.message = "Success"
                })
                debugPrint("Logged in user:", user)
               case .failure(let error):
                DispatchQueue.main.async(execute: {
                    self.message = "Failure"
                })
                debugPrint("Login error:", error.localizedDescription)
               }
        }
    }
}
