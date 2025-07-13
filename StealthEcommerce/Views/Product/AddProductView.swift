//
//  AddProductView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import SwiftUI

struct AddProductView: View {
    @StateObject private var viewModel = ProductViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Product Information")) {
                    TextField("Product Name", text: $viewModel.name)
                        .autocapitalization(.words)
                    
                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(4...)
                    
                    HStack {
                        Text("$")
                        TextField("Price", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $viewModel.category) {
                        Text("Select a category").tag("")
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Stock Quantity", text: $viewModel.stock)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Product Image")) {
                    TextField("Image URL", text: $viewModel.imageUrl)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    if !viewModel.imageUrl.isEmpty {
                        AsyncImage(url: URL(string: viewModel.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 200)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("Invalid URL or image failed to load")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                
                Section {
                    Button(action: submitProduct) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Add Product")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .listRowBackground(Color.blue)
                    .foregroundColor(.white)
                }
            }
            .navigationTitle("Add New Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $viewModel.showSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Product added successfully"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
            .overlay(
                Group {
                    if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Spacer()
                            Text(errorMessage)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red.opacity(0.9))
                                .cornerRadius(10)
                                .padding()
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        if viewModel.errorMessage == errorMessage {
                                            viewModel.errorMessage = nil
                                        }
                                    }
                                }
                        }
                    }
                }
            )
        }
    }
    
    private func submitProduct() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        viewModel.createProduct { success in
            if success {
                // The alert will handle dismissal
            }
        }
    }
}

#Preview {
    AddProductView()
} 