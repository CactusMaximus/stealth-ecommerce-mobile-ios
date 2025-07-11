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
