//
//  ShippingAddressView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct ShippingAddressView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var showingValidationAlert = false
    
    var onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Shipping Address")) {
                    TextField("Street", text: $street)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Zip Code", text: $zipCode)
                }
                
                Section {
                    Button("Continue to Payment") {
                        if validateFields() {
                            cartViewModel.updateShippingAddress(
                                street: street,
                                city: city,
                                state: state,
                                zipCode: zipCode
                            )
                            presentationMode.wrappedValue.dismiss()
                            onComplete()
                        } else {
                            showingValidationAlert = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Shipping Address")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // Pre-fill with existing address if available
                let address = cartViewModel.shippingAddress
                street = address.street
                city = address.city
                state = address.state
                zipCode = address.zipCode
            }
            .alert(isPresented: $showingValidationAlert) {
                Alert(
                    title: Text("Incomplete Information"),
                    message: Text("Please fill in all address fields."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func validateFields() -> Bool {
        return !street.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty
    }
}

#Preview {
    ShippingAddressView(onComplete: {})
        .environmentObject(CartViewModel())
} 