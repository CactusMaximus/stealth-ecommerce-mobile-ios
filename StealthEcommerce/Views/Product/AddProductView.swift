//
//  AddProductView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/13.
//

import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Product Details")) {
                    TextField("Name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                    TextField("Price", text: $viewModel.price)
                        .keyboardType(.decimalPad)
                    Picker("Category", selection: $viewModel.category) {
                        Text("Select a category").tag("")
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    TextField("Stock", text: $viewModel.stock)
                        .keyboardType(.numberPad)
                    TextField("Image URL", text: $viewModel.imageUrl)
                        .keyboardType(.URL)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Create Product") {
                        viewModel.createProduct { success in
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Product Created", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("The product was created successfully.")
            }
        }
    }
}

#Preview {
    AddProductView()
} 