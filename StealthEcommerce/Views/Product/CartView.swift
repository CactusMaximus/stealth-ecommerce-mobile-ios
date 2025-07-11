//
//  CartView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct CartView: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            orderItem
            orderItem
            orderItem
            Text("Summary").font(.title2).bold()
            HStack {
                Text("Subtotal").foregroundStyle(.gray)
                Spacer()
                Text("$85")
            }
            HStack {
                Text("Shipping").foregroundStyle(.gray)
                Spacer()
                Text("$5")
            }
            
            HStack {
                Text("Total").foregroundStyle(.gray)
                Spacer()
                Text("$90")
            }
            Spacer()
            Button(action: handleCheckout) {
                Text("Checkout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(50)
            }
           
            
        }.padding(20)
    }
    
   
    
    func handleCheckout() {
//        if username.isEmpty || password.isEmpty {
//            loginMessage = "Please enter both username and password."
//        } else {
//            loginMessage = "Logging in as \(username)..."
//            // Simulate login process
//        }
    }
    
    var orderItem: some View {
        HStack {
            Image("avo").resizable().scaledToFit().frame(width: 100).padding()
            VStack(alignment: .leading) {
                Text("to be changed")
                Text("Quantity: 3").foregroundStyle(.gray)
            }
            Spacer()
            Text("$20").bold()
        }
        
        
    }
}

#Preview {
    CartView()
}

