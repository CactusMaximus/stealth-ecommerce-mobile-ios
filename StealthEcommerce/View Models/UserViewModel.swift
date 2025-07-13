//
//  UserViewModel.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/10.
//

import Foundation

// We're using the EmptyRequest struct from OrderViewModel.swift
// struct EmptyRequest: Codable {}

class UserViewModel: ObservableObject {
    
    @Published var message: String?
    @Published var errorDetails: String?
    @Published var currentUser: UserResponse?
    @Published var isAdmin: Bool = false // Add isAdmin property
    @Published var isLoading = false
    @Published var isGoogleSignInLoading = false
    
    // For editing profile
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var street: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zipCode: String = ""
    
    private var networkService: NetworkService
    private var googleSignInManager = GoogleSignInManager.shared
    
    // Define EmptyRequest struct for GET requests
    struct EmptyRequest: Codable {}
    
    init(networkService: NetworkService = NetworkService.shared) {
        self.networkService = networkService
        
        // For testing purposes, set isAdmin to true
        // In a real app, this would be determined by the user's role from the API
        #if DEBUG
        isAdmin = true
        #endif
    }
    
    //POST User - Create a user
    func createUser(user: User) {
        isLoading = true
        networkService.authRequest(url: APIConstants.Endpoints.users, method: .post, body: user) { [weak self] (result: Result<UserResponse, Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.message = "Success"
                    self?.currentUser = user
                    self?.loadUserDataToForm()
                    // In a real app, you would check if the user has admin role
                    // self?.isAdmin = user.isAdmin
                    print("✅ Registered user:", user)
                case .failure(let error):
                    self?.message = "Failure"
                    
                    // Handle specific network errors
                    if let networkError = error as? NetworkService.NetworkError {
                        switch networkError {
                        case .serverError(let message, _):
                            self?.errorDetails = "Server error: \(message)"
                        case .decodingFailed(let decodingError):
                            if let decodingError = decodingError as? DecodingError {
                                switch decodingError {
                                case .keyNotFound(let key, _):
                                    self?.errorDetails = "Server response missing expected field: \(key.stringValue)"
                                case .valueNotFound(_, let context):
                                    self?.errorDetails = "Missing value: \(context.debugDescription)"
                                case .typeMismatch(_, let context):
                                    self?.errorDetails = "Type mismatch: \(context.debugDescription)"
                                default:
                                    self?.errorDetails = "Response format error: \(decodingError.localizedDescription)"
                                }
                            } else {
                                self?.errorDetails = "Failed to decode server response"
                            }
                        default:
                            self?.errorDetails = error.localizedDescription
                        }
                    } else {
                        self?.errorDetails = error.localizedDescription
                    }
                    
                    print("❌ Registration error:", error)
                }
            }
        }
    }
    
    //POST User - Login user
    func loginUser(email: String, password: String) {
        isLoading = true
        // Create a login request with just email and password
        let loginRequest = LoginRequest(email: email, password: password)
        
        networkService.authRequest(url: APIConstants.Endpoints.login, method: .post, body: loginRequest) { [weak self] (result: Result<UserResponse, Error>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.message = "Success"
                    self?.currentUser = user
                    self?.loadUserDataToForm()
                    // In a real app, you would check if the user has admin role
                    // self?.isAdmin = user.isAdmin
                    print("✅ Logged in user:", user)
                case .failure(let error):
                    self?.message = "Failure"
                    
                    // Handle specific network errors
                    if let networkError = error as? NetworkService.NetworkError {
                        switch networkError {
                        case .serverError(let message, let code):
                            if code == 418 {
                                self?.errorDetails = "Authentication failed. Please check your credentials and try again."
                                print("🫖 Server returned teapot error (418) - This typically means invalid credentials")
                            } else {
                                self?.errorDetails = "Server error: \(message)"
                            }
                        case .decodingFailed(let decodingError):
                            if let decodingError = decodingError as? DecodingError {
                                switch decodingError {
                                case .keyNotFound(let key, _):
                                    self?.errorDetails = "Server response missing expected field: \(key.stringValue)"
                                case .valueNotFound(_, let context):
                                    self?.errorDetails = "Missing value: \(context.debugDescription)"
                                case .typeMismatch(_, let context):
                                    self?.errorDetails = "Type mismatch: \(context.debugDescription)"
                                default:
                                    self?.errorDetails = "Response format error: \(decodingError.localizedDescription)"
                                }
                            } else {
                                self?.errorDetails = "Failed to decode server response"
                            }
                        default:
                            self?.errorDetails = error.localizedDescription
                        }
                    } else {
                        self?.errorDetails = error.localizedDescription
                    }
                    
                    print("❌ Login error:", error)
                }
            }
        }
    }
    
    // GET User - Fetch user details by ID
    func fetchUserDetails(userId: String) {
        isLoading = true
        let url = "\(APIConstants.Endpoints.users)/\(userId)"
        
        // Set a timeout to ensure isLoading is reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
        }
        
        // Use a custom completion handler to check status code first
        let task = URLSession.shared.dataTask(with: createRequest(url: url, method: .get, body: Optional<EmptyRequest>.none)) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorDetails = "Network error: \(error.localizedDescription)"
                    print("❌ User details fetch error:", error)
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")
                    
                    // Handle specific error codes
                    if httpResponse.statusCode == 404 {
                        self?.errorDetails = "User not found. Please check your account."
                        print("❌ User details fetch error: User not found")
                        return
                    }
                    
                    if httpResponse.statusCode == 418 {
                        self?.errorDetails = "Server error: I'm a teapot (418)"
                        print("❌ User details fetch error: I'm a teapot")
                        return
                    }
                    
                    if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                        // Try to parse error message from response
                        if let data = data, let errorResponse = try? JSONDecoder().decode([String: String].self, from: data) {
                            self?.errorDetails = errorResponse["error"] ?? "Server error: \(httpResponse.statusCode)"
                        } else {
                            self?.errorDetails = "Server error: \(httpResponse.statusCode)"
                        }
                        return
                    }
                }
                
                // If we got here, try to decode the successful response
                guard let data = data else {
                    self?.errorDetails = "No data received from server"
                    return
                }
                
                do {
                    let user = try JSONDecoder().decode(UserResponse.self, from: data)
                    self?.currentUser = user
                    self?.loadUserDataToForm()
                    print("✅ Fetched user details:", user)
                } catch {
                    print("❌ Decoding Error:", error)
                    self?.errorDetails = "Failed to fetch user details: \(error.localizedDescription)"
                }
            }
        }
        
        task.resume()
    }
    
    // PUT User - Update user profile
    func updateUserProfile(userId: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        // Create address from form data
        let address = Address(
            street: street,
            city: city,
            state: state,
            zipCode: zipCode
        )
        
        // Create update request
        struct UserUpdateRequest: Codable {
            let firstName: String
            let lastName: String
            let email: String
            let address: Address
        }
        
        let updateRequest = UserUpdateRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            address: address
        )
        
        let url = "\(APIConstants.Endpoints.users)/\(userId)"
        
        // Use a custom completion handler to check status code first
        let task = URLSession.shared.dataTask(with: createRequest(url: url, method: .put, body: updateRequest)) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorDetails = "Network error: \(error.localizedDescription)"
                    print("❌ Profile update error:", error)
                    completion(false)
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Response Status Code: \(httpResponse.statusCode)")
                    
                    // Handle 404 or other error status codes
                    if httpResponse.statusCode == 404 {
                        self?.errorDetails = "User not found. Please check your account."
                        print("❌ Profile update error: User not found")
                        completion(false)
                        return
                    }
                    
                    if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                        // Try to parse error message from response
                        if let data = data, let errorResponse = try? JSONDecoder().decode([String: String].self, from: data) {
                            self?.errorDetails = errorResponse["error"] ?? "Server error: \(httpResponse.statusCode)"
                        } else {
                            self?.errorDetails = "Server error: \(httpResponse.statusCode)"
                        }
                        completion(false)
                        return
                    }
                }
                
                // If we got here, try to decode the successful response
                guard let data = data else {
                    self?.errorDetails = "No data received from server"
                    completion(false)
                    return
                }
                
                do {
                    let user = try JSONDecoder().decode(UserResponse.self, from: data)
                    self?.currentUser = user
                    self?.loadUserDataToForm()
                    print("✅ Updated user profile:", user)
                    completion(true)
                } catch {
                    print("❌ Decoding Error:", error)
                    self?.errorDetails = "Failed to update profile: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
    
    // Sign in with Google
    func signInWithGoogle() {
        isGoogleSignInLoading = true
        
        googleSignInManager.signIn { [weak self] result in
            DispatchQueue.main.async {
                self?.isGoogleSignInLoading = false
                
                switch result {
                case .success(let googleUser):
                    // Handle successful Google sign-in
                    print("✅ Google Sign-In successful: \(googleUser.email)")
                    
                    // Check if user exists in our system
                    self?.authenticateGoogleUser(googleUser: googleUser)
                    
                case .failure(let error):
                    self?.message = "Failure"
                    self?.errorDetails = "Google Sign-In failed: \(error.localizedDescription)"
                    print("❌ Google Sign-In error:", error)
                }
            }
        }
    }
    
    // Authenticate Google user with our backend
    private func authenticateGoogleUser(googleUser: GoogleUser) {
        isLoading = true
        
        // Convert Google user to our User model and register directly
        let newUser = googleUser.toAppUser()
        createUser(user: newUser)
    }
    
    // Load user data to form fields for editing
    func loadUserDataToForm() {
        guard let user = currentUser else { return }
        
        firstName = user.firstName
        lastName = user.lastName
        email = user.email
        street = user.address.street
        city = user.address.city
        state = user.address.state
        zipCode = user.address.zipCode
    }
}

// Helper method to create URLRequest
private func createRequest<T: Encodable>(url: String, method: HTTPMethod, body: T?) -> URLRequest {
    guard let requestUrl = URL(string: url) else {
        fatalError("Invalid URL: \(url)")
    }
    
    var request = URLRequest(url: requestUrl)
    request.httpMethod = method.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let body = body {
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📦 Request Body: \(jsonString)")
            }
        } catch {
            print("❌ Error encoding request body: \(error)")
        }
    }
    
    return request
}
