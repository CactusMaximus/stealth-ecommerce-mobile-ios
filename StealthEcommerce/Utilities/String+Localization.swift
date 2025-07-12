//
//  String+Localization.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let localizedFormat = NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: self, comment: "")
        return String(format: localizedFormat, arguments: arguments)
    }
} 