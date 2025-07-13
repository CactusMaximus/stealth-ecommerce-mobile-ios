//
//  Category.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let imageUrl: String
}

struct HeroCard: Codable {
    let title: String
    let imageUrl: String
    let linkTo: String
}

struct HomeScreenData: Codable {
    let categories: [Category]
    let heroCard: HeroCard
} 