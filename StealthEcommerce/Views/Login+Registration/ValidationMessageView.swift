//
//  ValidationMessageView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct ValidationMessageView: View {
    var message: String
    
    var body: some View {
        if !message.isEmpty {
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top, 4)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ValidationMessageView(message: "This is an error message")
        ValidationMessageView(message: "")
    }
    .padding()
} 