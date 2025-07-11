//
//  AddressModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation

//Model for Address
struct Address: Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
}
