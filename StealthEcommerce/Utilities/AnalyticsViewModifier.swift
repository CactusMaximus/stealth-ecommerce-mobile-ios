import SwiftUI

// ViewModifier to track screen views
struct AnalyticsScreenTracker: ViewModifier {
    let screenName: String
    let screenClass: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                AnalyticsManager.shared.trackScreenView(screenName: screenName, screenClass: screenClass)
            }
    }
}

// Extension to make it easier to use
extension View {
    func trackScreenView(screenName: String, screenClass: String? = nil) -> some View {
        self.modifier(AnalyticsScreenTracker(
            screenName: screenName,
            screenClass: screenClass ?? String(describing: type(of: self))
        ))
    }
} 