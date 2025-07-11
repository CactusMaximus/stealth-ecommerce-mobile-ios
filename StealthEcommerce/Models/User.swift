//
//  User.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

struct User: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let address: Address
}

struct UserResponse: Decodable {
    let email: String
    let firstName: String
    let lastName: String
    let address: Address
    let _id: String
    let createdAt: String
    let updatedAt: String
    let __v: Int
}
