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
        guard let url = URL(string: "http://localhost:3000/api/users") else { return }
        
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
    
    func loginUser(user: User) {
        
        guard let url = URL(string: "http://localhost:3000/api/users/login") else { return }
        
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
