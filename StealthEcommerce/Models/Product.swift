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
    let price: Double
    let category: String
    let stock: Int
    let imageUrl: String

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case price
        case category
        case stock
        case imageUrl
    }
}

// Product creation request model
struct ProductCreationRequest: Codable {
    let name: String
    let description: String
    let price: Double
    let category: String
    let stock: Int
    let imageUrl: String
}
