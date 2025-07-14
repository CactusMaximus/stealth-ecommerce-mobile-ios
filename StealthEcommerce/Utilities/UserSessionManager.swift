import Foundation

class UserSessionManager {
    static let shared = UserSessionManager()
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "logged_in_user"
    
    private init() {}
    
    // Save user data to UserDefaults
    func saveUserSession(_ user: UserResponse) {
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            userDefaults.set(userData, forKey: userKey)
            userDefaults.synchronize()
            print("✅ User session saved successfully")
        } catch {
            print("❌ Failed to save user session: \(error)")
        }
    }
    
    // Load user data from UserDefaults
    func loadUserSession() -> UserResponse? {
        guard let userData = userDefaults.data(forKey: userKey) else {
            print("ℹ️ No saved user session found")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(UserResponse.self, from: userData)
            print("✅ User session loaded successfully")
            return user
        } catch {
            print("❌ Failed to load user session: \(error)")
            return nil
        }
    }
    
    // Clear user data from UserDefaults
    func clearUserSession() {
        userDefaults.removeObject(forKey: userKey)
        userDefaults.synchronize()
        print("✅ User session cleared")
    }
    
    // Check if a user is logged in
    func isUserLoggedIn() -> Bool {
        return userDefaults.object(forKey: userKey) != nil
    }
} 