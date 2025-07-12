//
//  ValidationMessageView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct ValidationMessageView: View {
    let message: String
    
    var body: some View {
        if !message.isEmpty {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                Spacer()
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    ValidationMessageView(message: "This field is required")
} 