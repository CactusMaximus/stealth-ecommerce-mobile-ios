import Foundation
import SwiftUI
import AuthenticationServices
import UIKit
import GoogleSignIn

class GoogleSignInManager: ObservableObject {
    static let shared = GoogleSignInManager()
    
    @Published var isSigningIn = false
    @Published var signInError: String?
    
    private init() {
        // Google Sign-In is initialized in AppDelegate
    }
    
    func signIn(completion: @escaping (Result<GoogleUser, Error>) -> Void) {
        isSigningIn = true
        signInError = nil
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            isSigningIn = false
            let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
            completion(.failure(error))
            return
        }
        
        // Use a simple implementation that should work with any version
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            DispatchQueue.main.async {
                self.isSigningIn = false
                
                if let error = error {
                    print("❌ Google Sign-In error:", error)
                    self.signInError = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                guard let signInResult = signInResult else {
                    let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No result returned"])
                    completion(.failure(error))
                    return
                }
                
                let user = signInResult.user
                
                // Create our GoogleUser model
                let googleUser = GoogleUser(
                    id: user.userID ?? UUID().uuidString,
                    email: user.profile?.email ?? "",
                    firstName: user.profile?.givenName ?? "User",
                    lastName: user.profile?.familyName ?? "Name",
                    profilePictureURL: user.profile?.imageURL(withDimension: 100)?.absoluteString ?? ""
                )
                
                print("✅ Google Sign-In successful: \(googleUser.email)")
                completion(.success(googleUser))
            }
        }
    }
    
    func handleSignInCallback(url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// Model to represent a Google user
struct GoogleUser {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let profilePictureURL: String
}

// Extension to convert GoogleUser to our app's User model
extension GoogleUser {
    func toAppUser() -> User {
        return User(
            email: email,
            password: UUID().uuidString, // Generate a random password for SSO users
            firstName: firstName,
            lastName: lastName,
            address: Address(
                street: "Default Street", 
                city: "Default City", 
                state: "Default State", 
                zipCode: "00000"
            )
        )
    }
} 