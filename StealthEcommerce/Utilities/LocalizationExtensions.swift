import Foundation
import SwiftUI

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let localizedFormat = NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: self, comment: "")
        return String(format: localizedFormat, arguments: arguments)
    }
}

// MARK: - SwiftUI Text Extension
extension Text {
    static func localized(_ key: String) -> Text {
        return Text(key.localized)
    }
    
    static func localized(_ key: String, with arguments: CVarArg...) -> Text {
        return Text(key.localized(with: arguments))
    }
}

// MARK: - SwiftUI TextField Extension
extension TextField where Label == Text {
    static func localized(_ titleKey: String, text: Binding<String>) -> TextField {
        return TextField(titleKey.localized, text: text)
    }
}

// MARK: - SwiftUI SecureField Extension
extension SecureField where Label == Text {
    static func localized(_ titleKey: String, text: Binding<String>) -> SecureField {
        return SecureField(titleKey.localized, text: text)
    }
}

// MARK: - SwiftUI Button Extension
extension Button where Label == Text {
    static func localized(_ titleKey: String, action: @escaping () -> Void) -> Button {
        return Button(action: action) {
            Text(titleKey.localized)
        }
    }
} 