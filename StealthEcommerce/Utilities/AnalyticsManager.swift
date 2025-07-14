import Foundation
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // Track screen views
    func trackScreenView(screenName: String, screenClass: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass
        ])
        #else
        trackEvent(name: AnalyticsConstants.eventScreenView, parameters: [
            AnalyticsConstants.parameterScreenName: screenName,
            AnalyticsConstants.parameterScreenClass: screenClass
        ])
        #endif
        print("📊 Analytics - Screen View: \(screenName)")
    }
    
    // Track user actions
    func trackEvent(name: String, parameters: [String: Any]? = nil) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(name, parameters: parameters)
        #endif
        print("📊 Analytics - Event: \(name), Parameters: \(parameters ?? [:])")
    }
    
    // Track user properties
    func setUserProperty(value: String?, forName name: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserProperty(value, forName: name)
        #endif
        print("📊 Analytics - User Property: \(name) = \(value ?? "nil")")
    }
    
    // Track user ID (when logged in)
    func setUserID(userID: String?) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserID(userID)
        #endif
        print("📊 Analytics - User ID: \(userID ?? "nil")")
    }
    
    // Common events
    func trackLogin(method: String) {
        #if canImport(FirebaseAnalytics)
        trackEvent(name: AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
        #else
        trackEvent(name: AnalyticsConstants.eventLogin, parameters: [
            AnalyticsConstants.parameterMethod: method
        ])
        #endif
    }
    
    func trackSignUp(method: String) {
        #if canImport(FirebaseAnalytics)
        trackEvent(name: AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
        #else
        trackEvent(name: AnalyticsConstants.eventSignUp, parameters: [
            AnalyticsConstants.parameterMethod: method
        ])
        #endif
    }
    
    func trackAddToCart(product: Product, quantity: Int) {
        #if canImport(FirebaseAnalytics)
        trackEvent(name: AnalyticsEventAddToCart, parameters: [
            AnalyticsParameterItemID: product.id,
            AnalyticsParameterItemName: product.name,
            AnalyticsParameterPrice: product.price,
            AnalyticsParameterQuantity: quantity,
            AnalyticsParameterCurrency: "USD"
        ])
        #else
        trackEvent(name: AnalyticsConstants.eventAddToCart, parameters: [
            AnalyticsConstants.parameterItemID: product.id,
            AnalyticsConstants.parameterItemName: product.name,
            AnalyticsConstants.parameterPrice: product.price,
            AnalyticsConstants.parameterQuantity: quantity,
            AnalyticsConstants.parameterCurrency: "USD"
        ])
        #endif
    }
    
    func trackPurchase(orderId: String, total: Double, items: [CartItem]) {
        var itemsArray: [[String: Any]] = []
        
        for item in items {
            itemsArray.append([
                AnalyticsConstants.parameterItemID: item.product.id,
                AnalyticsConstants.parameterItemName: item.product.name,
                AnalyticsConstants.parameterPrice: item.product.price,
                AnalyticsConstants.parameterQuantity: item.quantity
            ])
        }
        
        #if canImport(FirebaseAnalytics)
        trackEvent(name: AnalyticsEventPurchase, parameters: [
            AnalyticsParameterTransactionID: orderId,
            AnalyticsParameterValue: total,
            AnalyticsParameterCurrency: "USD",
            AnalyticsParameterItems: itemsArray
        ])
        #else
        trackEvent(name: AnalyticsConstants.eventPurchase, parameters: [
            AnalyticsConstants.parameterTransactionID: orderId,
            AnalyticsConstants.parameterValue: total,
            AnalyticsConstants.parameterCurrency: "USD",
            AnalyticsConstants.parameterItems: itemsArray
        ])
        #endif
    }
} 