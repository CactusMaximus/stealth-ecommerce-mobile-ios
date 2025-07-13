//
//  LocalizationExtensions.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/13.
//

import Foundation
import SwiftUI

// Extension for String to get localized version
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

// Extensions for SwiftUI components to use localization
extension Text {
    static func localized(_ key: String) -> Text {
        return Text(key.localized)
    }
}

extension TextField where Label == Text {
    static func localized(_ key: String, text: Binding<String>) -> TextField<Text> {
        return TextField(key.localized, text: text)
    }
}

extension SecureField where Label == Text {
    static func localized(_ key: String, text: Binding<String>) -> SecureField<Text> {
        return SecureField(key.localized, text: text)
    }
} 