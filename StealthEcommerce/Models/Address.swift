//
//  AddressModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation

//Model for Address
struct Address: Codable {
    var street: String
    var city: String
    var state: String
    var zipCode: String
    
    init(street: String = "", city: String = "", state: String = "", zipCode: String = "") {
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
    }
}
