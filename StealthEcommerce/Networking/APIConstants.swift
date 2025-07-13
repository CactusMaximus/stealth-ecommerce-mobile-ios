import Foundation

struct APIConstants {
    // Set to true to use actual API calls instead of mock data
    static let useLocalhost = true
    
    // Base URLs
    private static let localhostURL = "http://localhost:3000/api"
    private static let productionURL = "https://your-production-server.com/api" // Update with your actual production URL
    
    // For simulator/device testing with a local server
    // Replace this with your computer's actual IP address on your network
    // You can find this in System Settings > Network or by running 'ifconfig' in Terminal
    static let localIPAddress = "192.168.1.100" // REPLACE WITH YOUR ACTUAL IP ADDRESS
    static let localServerPort = "3000"
    static let localNetworkURL = "http://\(localIPAddress):\(localServerPort)/api"
    
    // Active base URL based on environment
    static let baseURL = useLocalhost ? localhostURL : productionURL
    
    // URL specifically for iOS devices and simulators to connect to your local development server
    static let deviceBaseURL = localNetworkURL
    
    struct Endpoints {
        static let products = "\(baseURL)/products"
        static let users = "\(baseURL)/users"
        static let orders = "\(baseURL)/orders"
        static let login = "\(baseURL)/users/login"
        static let googleAuth = "\(baseURL)/users/google-auth"
        static let home = "\(baseURL)/home"
        
        // Device-specific endpoints for connecting to local server
        static let deviceProducts = "\(deviceBaseURL)/products"
        static let deviceUsers = "\(deviceBaseURL)/users"
        static let deviceOrders = "\(deviceBaseURL)/orders"
        static let deviceLogin = "\(deviceBaseURL)/users/login"
        static let deviceGoogleAuth = "\(deviceBaseURL)/users/google-auth"
        static let deviceHome = "\(deviceBaseURL)/home"
    }
    
    // Debug function to print all endpoints
    static func printAllEndpoints() {
        print("🔗 API Endpoints:")
        print("Base URL: \(baseURL)")
        print("Device Base URL: \(deviceBaseURL)")
        print("Products: \(Endpoints.products)")
        print("Users: \(Endpoints.users)")
        print("Orders: \(Endpoints.orders)")
        print("Login: \(Endpoints.login)")
        print("Google Auth: \(Endpoints.googleAuth)")
        print("Home: \(Endpoints.home)")
        print("Device Products: \(Endpoints.deviceProducts)")
        print("Device Users: \(Endpoints.deviceUsers)")
        print("Device Orders: \(Endpoints.deviceOrders)")
        print("Device Login: \(Endpoints.deviceLogin)")
        print("Device Google Auth: \(Endpoints.deviceGoogleAuth)")
        print("Device Home: \(Endpoints.deviceHome)")
    }
    
    // Helper function to check if the API server is reachable
    static func checkServerConnection(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(false, "Invalid base URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(false, "Connection error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, "Invalid response")
                return
            }
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                completion(true, nil)
            } else {
                completion(false, "Server returned status code: \(httpResponse.statusCode)")
            }
        }
        
        task.resume()
    }
} 