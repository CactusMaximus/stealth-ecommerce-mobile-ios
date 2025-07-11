//
//  HeroView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct HeroView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: -100) {
            Image("hero", bundle: .main)
                .resizable()
                .scaledToFit()
                .padding()
            Text("Featured Items")
                .font(.largeTitle)
                .foregroundStyle(Color(.white))
                .padding(30)
                .bold()
        }.padding(-20)
    }
}

#Preview {
    HeroView()
}
