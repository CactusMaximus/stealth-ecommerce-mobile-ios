//
//  NetworkService.swift
//  StealthEcommerce
//
//  Created by Shamith Ramdhani on 2025/07/11.
//
import Foundation

// Define supported HTTP methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class NetworkService {
    static let shared = NetworkService() // Singleton
    
    // Configure session with increased limits for large responses
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        // Increase memory capacity to 50 MB (was 10 MB)
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, 
                                  diskCapacity: 100 * 1024 * 1024,
                                  diskPath: "NetworkServiceCache")
        // Increase timeout to 90 seconds
        config.timeoutIntervalForRequest = 90.0
        config.timeoutIntervalForResource = 90.0
        // Allow cellular access
        config.allowsCellularAccess = true
        // Increase HTTP maximum connections per host
        config.httpMaximumConnectionsPerHost = 5
        return URLSession(configuration: config)
    }()
    
    private init() {}

    // Special function for auth requests that might return error messages instead of user objects
    func authRequest<U: Encodable>(
        url: String,
        method: HTTPMethod,
        body: U? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<UserResponse, Error>) -> Void
    ) {
        guard let requestUrl = URL(string: url) else {
            print("❌ Invalid URL: \(url)")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        print("🔐 Auth \(method.rawValue) Request to: \(url)")
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📦 Request Body: \(jsonString)")
                }
            } catch {
                print("❌ Error encoding request body: \(error)")
                completion(.failure(NetworkError.encodingFailed))
                return
            }
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            print("📡 Response Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(NetworkError.noData))
                return
            }

            // Print response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Data: \(responseString)")
            }
            
            // Check for error response first
            if httpResponse.statusCode >= 400 {
                // Special handling for 418 status code
                if httpResponse.statusCode == 418 {
                    completion(.failure(NetworkError.serverError(message: "I'm a teapot (418) - The server refuses to brew coffee because it is a teapot.", code: 418)))
                    return
                }
                
                // Try to decode as error response
                do {
                    let errorResponse = try JSONDecoder().decode([String: String].self, from: data)
                    if let errorMessage = errorResponse["error"] {
                        completion(.failure(NetworkError.serverError(message: errorMessage, code: httpResponse.statusCode)))
                        return
                    }
                } catch {
                    // If we can't decode the error, just return the status code
                    completion(.failure(NetworkError.serverError(message: "Server error", code: httpResponse.statusCode)))
                    return
                }
            }

            // If we get here, try to decode as UserResponse
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let user = try decoder.decode(UserResponse.self, from: data)
                print("✅ Successfully decoded user response")
                completion(.success(user))
            } catch {
                print("❌ Decoding Error: \(error)")
                
                // More detailed decoding error information
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key), context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type), context: \(context.debugDescription)")
                    default:
                        print("Other decoding error: \(decodingError)")
                    }
                }
                
                completion(.failure(NetworkError.decodingFailed(error)))
            }
        }.resume()
    }

    func request<T: Decodable, U: Encodable>(
        url: String,
        method: HTTPMethod,
        body: U? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let requestUrl = URL(string: url) else {
            print("❌ Invalid URL: \(url)")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        print("🌐 \(method.rawValue) Request to: \(url)")
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("📦 Request Body: \(jsonString)")
                }
            } catch {
                print("❌ Error encoding request body: \(error)")
                completion(.failure(NetworkError.encodingFailed))
                return
            }
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response Status Code: \(httpResponse.statusCode)")
                
                // Check for large response
                if let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length"),
                   let size = Int(contentLength) {
                    print("📊 Response size: \(size) bytes (\(size / 1024) KB)")
                }
            }

            guard let data = data else {
                print("❌ No data received")
                completion(.failure(NetworkError.noData))
                return
            }

            // Print response size
            print("📊 Actual data size: \(data.count) bytes (\(data.count / 1024) KB)")
            
            // For large responses, don't print the entire response
            if data.count < 1024 * 10 { // Only print if less than 10KB
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Response Data: \(responseString)")
                }
            } else {
                print("📥 Response too large to print (\(data.count / 1024) KB)")
                
                // Print just the beginning to help with debugging
                if let partialString = String(data: data.prefix(1000), encoding: .utf8) {
                    print("📥 First 1000 bytes: \(partialString)...")
                }
            }

            do {
                let decoder = JSONDecoder()
                // Configure date decoding strategy if needed
                decoder.dateDecodingStrategy = .iso8601
                
                let decoded = try decoder.decode(T.self, from: data)
                print("✅ Successfully decoded response of type: \(T.self)")
                completion(.success(decoded))
            } catch {
                print("❌ Decoding Error: \(error)")
                
                // More detailed decoding error information
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key), context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type), context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: expected \(type), context: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                
                completion(.failure(NetworkError.decodingFailed(error)))
            }
        }.resume()
    }

    //Error enum
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case encodingFailed
        case noData
        case decodingFailed(Error)
        case serverError(message: String, code: Int)
    }
}

