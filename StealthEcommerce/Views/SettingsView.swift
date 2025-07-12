//
//  SettingsView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var regionManager = RegionManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Regional Preferences")) {
                    RegionSelectorView()
                }
                
                Section(header: Text("Account")) {
                    Button("Sign Out") {
                        // Handle sign out
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
} 