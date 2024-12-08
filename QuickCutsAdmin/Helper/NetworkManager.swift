//
//  NetworkManager.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 24/11/24.
//

import Foundation

class NetworkManager {
    static func performRequest(
        url: URL,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: [String: Any]? = nil,
        viewModel: MainViewModel,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Default headers (Content-Type is required for most cases)
        var requestHeaders: [String: String] = ["Content-Type": "application/json"]
        
        // Add Authorization if a token exists
        if let authToken = AppDataManager.shared.getAuthToken() {
            requestHeaders["Authorization"] = "Bearer \(authToken)"
        }
        
        // Merge with provided headers
        headers?.forEach { key, value in
            requestHeaders[key] = value
        }
        
        // Add headers to request
        requestHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add body for POST, PUT, DELETE if provided
        if let body = body, ["POST", "PUT", "DELETE", "GET"].contains(method) {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(.failure(error))
                return
            }
        }

        // Execute the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                }
            } else if httpResponse.statusCode == 401 {
                DispatchQueue.main.async {
                    viewModel.handleUnauthorized()
                }
                completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
            } else {
                if let data = data {
                    completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: ["data": data])))
                } else {
                    completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: nil)))
                }
            }
        }.resume()
    }
}


