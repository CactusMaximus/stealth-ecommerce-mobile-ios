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
    private init() {}

    func request<T: Decodable, U: Encodable>(
        url: String,
        method: HTTPMethod,
        body: U? = nil,
        headers: [String: String] = [:],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let requestUrl = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(NetworkError.encodingFailed))
                return
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                debugPrint(decoded)
                completion(.success(decoded))
            } catch {
                debugPrint(error)
                completion(.failure(NetworkError.decodingFailed(error)))
            }
        }.resume()
    }

    //Error enum
    enum NetworkError: Error {
        case invalidURL
        case encodingFailed
        case noData
        case decodingFailed(Error)
    }
}

