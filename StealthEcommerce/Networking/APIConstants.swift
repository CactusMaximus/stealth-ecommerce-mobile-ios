import Foundation

struct APIConstants {
    // Set to true to use localhost, false to use the production server
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
        
        // Device-specific endpoints for connecting to local server
        static let deviceProducts = "\(deviceBaseURL)/products"
        static let deviceUsers = "\(deviceBaseURL)/users"
        static let deviceOrders = "\(deviceBaseURL)/orders"
        static let deviceLogin = "\(deviceBaseURL)/users/login"
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
        print("Device Products: \(Endpoints.deviceProducts)")
        print("Device Users: \(Endpoints.deviceUsers)")
        print("Device Orders: \(Endpoints.deviceOrders)")
        print("Device Login: \(Endpoints.deviceLogin)")
    }
} 