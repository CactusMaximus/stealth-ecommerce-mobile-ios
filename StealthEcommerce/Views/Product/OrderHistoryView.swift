//
//  OrderHistoryView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var orderViewModel = OrderViewModel()
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var refreshToggle: Bool = false
    let userId: String
    
    var body: some View {
        VStack {
            if orderViewModel.isLoading {
                ProgressView("order.history.loading".localized)
            } else if orderViewModel.orders.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    Text("order.history.empty".localized)
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("order.history.start_shopping".localized)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(orderViewModel.orders) { order in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("order.history.order_number".localized(with: String(order.id.suffix(6))))
                                    .font(.headline)
                                Spacer()
                                Text(order.formattedDate)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("cart.item_count".localized(with: order.items.count))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("order.history.total".localized(with: order.totalAmount))
                                    .font(.headline)
                            }
                            
                            HStack {
                                Text("order.history.status".localized(with: getLocalizedStatus(for: order.status)))
                                    .foregroundColor(statusColor(for: order.status))
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    orderViewModel.fetchOrderHistory(userId: userId)
                }
            }
        }
        .navigationTitle("order.history.title".localized)
        .onAppear {
            // For demo purposes, load mock orders instead of real API calls
            orderViewModel.useMockData = true
            orderViewModel.loadMockOrders()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionChanged"))) { _ in
            // Force refresh by toggling state
            refreshToggle.toggle()
        }
        .id(refreshToggle) // Force view recreation when language changes
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "processing":
            return .blue
        case "shipped":
            return .purple
        case "delivered":
            return .green
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
    
    private func getLocalizedStatus(for status: String) -> String {
        switch status.lowercased() {
        case "pending":
            return "status.pending".localized
        case "processing":
            return "status.processing".localized
        case "shipped":
            return "status.shipped".localized
        case "delivered":
            return "status.delivered".localized
        case "cancelled":
            return "status.cancelled".localized
        default:
            return status.capitalized
        }
    }
}

#Preview {
    NavigationView {
        OrderHistoryView(userId: "user123")
            .environmentObject(LocalizationManager.shared)
    }
} 