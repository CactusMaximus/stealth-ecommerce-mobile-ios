//
//  CategoryView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct CategoryView: View {
    var title = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("tools", bundle: .main).cornerRadius(15)
            Text(title).font(.title).fontWeight(.medium)
        }
       
    }
}

#Preview {
    CategoryView()
}
