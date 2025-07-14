//
//  HeroView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct HeroView: View {
    var heroCard: HeroCard?
    
    var body: some View {
        VStack(alignment: .leading, spacing: -100) {
            if let heroCard = heroCard, let url = URL(string: heroCard.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Image("hero", bundle: .main)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding()
                    case .failure:
                        Image("hero", bundle: .main)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    @unknown default:
                        Image("hero", bundle: .main)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                }
            } else {
                Image("hero", bundle: .main)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            
            Text(heroCard?.title ?? "Featured Items")
                .font(.largeTitle)
                .foregroundStyle(Color(.gray))
                .padding(30)
                .bold()
        }.padding(-20)
    }
}

#Preview {
    HeroView(heroCard: HeroCard(title: "Featured Items", imageUrl: "hero", linkTo: "/featured"))
}
