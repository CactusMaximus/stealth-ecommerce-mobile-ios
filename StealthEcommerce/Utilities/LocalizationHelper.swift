//
//  LocalizationHelper.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation
import SwiftUI

// Extension to Text for SwiftUI
extension Text {
    static func localized(_ key: String) -> Text {
        return Text(key.localized)
    }
    
    static func localized(_ key: String, with arguments: CVarArg...) -> Text {
        return Text(key.localized(with: arguments))
    }
}

// Extension to TextField for SwiftUI
extension TextField where Label == Text {
    static func localized(
        _ titleKey: String,
        text: Binding<String>
    ) -> TextField<Text> {
        return TextField(titleKey.localized, text: text)
    }
}

// Extension to SecureField for SwiftUI
extension SecureField where Label == Text {
    static func localized(
        _ titleKey: String,
        text: Binding<String>
    ) -> SecureField<Text> {
        return SecureField(titleKey.localized, text: text)
    }
} 