//
//  User.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

//Model for User Request
struct User: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let address: Address
}

//Model for User Response
struct UserResponse: Codable {
    var email: String
    var firstName: String
    var lastName: String
    var address: Address
    let _id: String
    let createdAt: String
    let updatedAt: String
    let __v: Int
    
    var id: String {
        return _id
    }
}
