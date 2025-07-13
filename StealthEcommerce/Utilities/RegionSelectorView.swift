//
//  RegionSelectorView.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/13.
//

import SwiftUI

// Region selector view for language selection
struct RegionSelectorView: View {
    @State private var showLanguages = false
    @ObservedObject private var regionManager = RegionManager.shared
    
    var body: some View {
        Menu {
            ForEach(USRegion.allCases) { region in
                Button(region.displayName) {
                    regionManager.setRegion(region)
                }
            }
        } label: {
            HStack {
                Text(regionManager.currentRegion.flag)
                Text(regionManager.currentRegion.shortName)
                    .font(.footnote)
            }
        }
    }
} 