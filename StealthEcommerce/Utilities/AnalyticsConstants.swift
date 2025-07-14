import Foundation

// Firebase Analytics parameter constants
// These are defined to match Firebase's constants but allow the app to compile even without Firebase
struct AnalyticsConstants {
    // Event names
    static let eventScreenView = "screen_view"
    static let eventLogin = "login"
    static let eventSignUp = "sign_up"
    static let eventAddToCart = "add_to_cart"
    static let eventPurchase = "purchase"
    static let eventViewItem = "view_item"
    
    // Parameter names
    static let parameterScreenName = "screen_name"
    static let parameterScreenClass = "screen_class"
    static let parameterMethod = "method"
    static let parameterItemID = "item_id"
    static let parameterItemName = "item_name"
    static let parameterPrice = "price"
    static let parameterQuantity = "quantity"
    static let parameterCurrency = "currency"
    static let parameterTransactionID = "transaction_id"
    static let parameterValue = "value"
    static let parameterItems = "items"
} 