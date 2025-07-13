//
//  ProfileView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct ProfileView: View {
    // Hardcoded user ID for demo purposes - in a real app, this would come from user authentication
    let userId = "65f5a1d2e1b7c2a3d4f5e6a7"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Account Settings")) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.yellow)
                            Text("Account Settings")
                        }
                    }
                    
                    NavigationLink(destination: Text("Payment Methods")) {
                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(.yellow)
                            Text("Payment Methods")
                        }
                    }
                }
                
                Section(header: Text("Orders")) {
                    NavigationLink(destination: OrderHistoryView(userId: userId)) {
                        HStack {
                            Image(systemName: "bag")
                                .foregroundColor(.yellow)
                            Text("Order History")
                        }
                    }
                    
                    NavigationLink(destination: Text("Saved Items")) {
                        HStack {
                            Image(systemName: "heart")
                                .foregroundColor(.yellow)
                            Text("Saved Items")
                        }
                    }
                }
                
                Section(header: Text("Support")) {
                    NavigationLink(destination: Text("Help Center")) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.yellow)
                            Text("Help Center")
                        }
                    }
                    
                    NavigationLink(destination: Text("Contact Us")) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.yellow)
                            Text("Contact Us")
                        }
                    }
                }
                
                Button(action: {
                    // Logout functionality would go here
                    print("Logout tapped")
                }) {
                    HStack {
                        Spacer()
                        Text("Logout")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
