//
//  UserViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation

class UserViewModel: ObservableObject {
    
    @Published var message: String?
    
    func createUser(user: User) {
        networkRequest(url: "http://localhost:3000/api/users", user: user)
    }
    
    func loginUser(user: User) {
        networkRequest(url:  "http://localhost:3000/api/users/login", user: user)
    }
    
    private func networkRequest(url: String, user: User) {
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
        } catch {
            print("Encoding error:\(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Network error\(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.message = "Response: \(responseString)"
                }
            }
        }.resume()
    }
}
