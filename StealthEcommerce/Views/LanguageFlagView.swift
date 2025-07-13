//
//  LanguageFlagView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/12.
//

import SwiftUI

struct LanguageFlagView: View {
    let region: USRegion
    let isSelected: Bool
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 8) {
            Text(region.flag)
                .font(.title2)
                .shadow(color: isSelected ? .yellow.opacity(0.8) : .clear, radius: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(region.shortName)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                if isHovering || isSelected {
                    Text(region.displayName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.yellow.opacity(0.2) : Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    HStack {
        LanguageFlagView(region: .american, isSelected: true)
        LanguageFlagView(region: .british, isSelected: false)
        LanguageFlagView(region: .spanish, isSelected: false)
    }
    .padding()
} 