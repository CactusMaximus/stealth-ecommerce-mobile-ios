//
//  CategoryView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct CategoryView: View {
    var category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Try to load from URL first, fallback to local image
            if let url = URL(string: category.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Image("tools", bundle: .main)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .cornerRadius(15)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .cornerRadius(15)
                    case .failure:
                        Image("tools", bundle: .main)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .cornerRadius(15)
                    @unknown default:
                        Image("tools", bundle: .main)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .cornerRadius(15)
                    }
                }
            } else {
                Image("tools", bundle: .main)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .cornerRadius(15)
            }
            
            Text(category.name)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }
}

#Preview {
    CategoryView(category: Category(id: "tools", name: "Tools", imageUrl: "tools"))
}
