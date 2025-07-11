//
//  Product.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

//Model for Product
struct Product: Codable, Identifiable {
    var id: String
    let name: String
    let description: String
    let price: String
    let category: String
}
