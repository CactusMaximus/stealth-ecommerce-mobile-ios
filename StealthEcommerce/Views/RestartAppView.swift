//
//  RestartAppView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct RestartAppView: View {
    @Binding var isPresented: Bool
    let languageName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("restart.title".localized)
                .font(.title)
                .bold()
            
            Text("restart.message".localized(with: languageName))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("restart.recommendation".localized)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // Close this view
                isPresented = false
                
                // Exit the app
                exit(0)
            }) {
                Text("restart.button.now".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Button(action: {
                // Just close this view
                isPresented = false
            }) {
                Text("restart.button.later".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    RestartAppView(isPresented: .constant(true), languageName: "English (US)")
} 