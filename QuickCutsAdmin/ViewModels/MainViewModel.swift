//
//  MainViewModel.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 22/11/24.
//

import Foundation
import UIKit
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var isServiceAdded: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showAlert: Bool = false
    @Published var profileImageURL: String? = nil
    @Published var salonDetails: Salon?
    @Published var services: [Service]? = []
    
    @Published var isRegistered = false
    @Published var isLoggedIn: Bool = false
    
    let baseUrl: String = "http://192.168.1.2:7700/api"
    let cloudinaryURL = "https://api.cloudinary.com/v1_1/dx3sjrkgg/image/upload"
    let cloudinaryPreset = "salon-services"
    let cloudinaryFolder = "salon-services/images"
    
    init() {
        isLoggedIn = AppDataManager.shared.isLoggedIn()
    }
    
    func fetchSalonServices() {
        guard let salon = AppDataManager.shared.getSalon() else {
            self.showError(message: "Salon not found. Please log in again.")
            return
        }
        
        guard let salonId = salon.id else {
            self.showError(message: "Salon ID not found. Please log in again.")
            return
        }

        guard let url = URL(string: "\(baseUrl)/salons/\(salonId)/services") else {
            self.showError(message: "Invalid URL for fetching salon services.")
            return
        }

        NetworkManager.performRequest(url: url, method: "GET", viewModel: self) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let serviceResponse = try JSONDecoder().decode(ServiceResponse.self, from: data)
                    DispatchQueue.main.async {
                        if let success = serviceResponse.success, success {
                            self?.services = serviceResponse.data
                            print("Services fetched successfully: \(serviceResponse.data)")
                        } else {
                            self?.showError(message: "Failed to fetch services: Unexpected response.")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.showError(message: "Failed to decode services: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if let nsError = error as? NSError,
                       let errorData = nsError.userInfo["data"] as? Data,
                       let errorResponse = String(data: errorData, encoding: .utf8) {
                        self?.showError(message: "Error fetching services: \(errorResponse)")
                    } else {
                        self?.showError(message: "Error fetching services: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func updateMainPicture(serviceImage: UIImage) {
        // Ensure the image data is valid
        guard let imageData = serviceImage.jpegData(compressionQuality: 0.8) else {
            self.showError(message: "Failed to process the selected image.")
            return
        }
        
        
        // Upload image to Cloudinary
        var cloudinaryRequest = URLRequest(url: URL(string: cloudinaryURL)!)
        cloudinaryRequest.httpMethod = "POST"
        cloudinaryRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        let boundary = UUID().uuidString
        cloudinaryRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = createMultipartBody(
            boundary: boundary,
            parameters: [
                "upload_preset": cloudinaryPreset,
                "folder": cloudinaryFolder
            ],
            filePathKey: "file",
            imageData: imageData,
            mimeType: "image/jpeg",
            fileName: "serviceImage.jpg"
        )
        cloudinaryRequest.httpBody = body
        
        URLSession.shared.dataTask(with: cloudinaryRequest) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError(message: "Cloudinary upload failed: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self?.showError(message: "Failed to upload image. Please try again.")
                }
                return
            }
            
            do {
                // Parse Cloudinary response
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let imageUrl = json["secure_url"] as? String {
                    print("Image uploaded successfully: \(imageUrl)")
                    self?.updateMainPictureOnBackend(imageUrl: imageUrl)
                } else {
                    DispatchQueue.main.async {
                        self?.showError(message: "Failed to parse Cloudinary response.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.showError(message: "Error parsing Cloudinary response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func updateMainPictureOnBackend(imageUrl: String) {
        // Backend API endpoint
        guard let url = URL(string: "\(baseUrl)/salons/profile/main-picture") else {
            self.showError(message: "Invalid backend URL.")
            return
        }
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization token if required
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Prepare JSON body
        let body: [String: Any] = ["mainPicture": imageUrl]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            self.showError(message: "Failed to encode JSON body: \(error.localizedDescription)")
            return
        }
        
        // Perform URLSession data task
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError(message: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self?.showError(message: "Invalid server response.")
                }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    print("Image URL successfully updated on backend.")
                    self?.profileImageURL = imageUrl
                    
                }
            } else {
                if let data = data,
                   let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = errorResponse["message"] as? String {
                    DispatchQueue.main.async {
                        self?.showError(message: message)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showError(message: "Server error with status code \(httpResponse.statusCode).")
                    }
                }
            }
        }.resume()
    }
    
    private func createMultipartBody(boundary: String, filePathKey: String, imageData: Data, mimeType: String, fileName: String) -> Data {
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    func addNewService(serviceName: String, price: String, serviceImage: UIImage) {
        // Check for valid inputs
        guard !serviceName.isEmpty else {
            self.showError(message: "Service name cannot be empty.")
            return
        }
        guard !price.isEmpty, let _ = Double(price) else {
            self.showError(message: "Invalid price. Please enter a valid number.")
            return
        }
        guard let imageData = serviceImage.jpegData(compressionQuality: 0.8) else {
            self.showError(message: "Failed to process the selected image.")
            return
        }
        
        // Upload image to Cloudinary
        var cloudinaryRequest = URLRequest(url: URL(string: cloudinaryURL)!)
        cloudinaryRequest.httpMethod = "POST"
        cloudinaryRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        let boundary = UUID().uuidString
        cloudinaryRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = createMultipartBody(
            boundary: boundary,
            parameters: [
                "upload_preset": cloudinaryPreset,
                "folder": cloudinaryFolder
            ],
            filePathKey: "file",
            imageData: imageData,
            mimeType: "image/jpeg",
            fileName: "serviceImage.jpg"
        )
        cloudinaryRequest.httpBody = body
        
        URLSession.shared.dataTask(with: cloudinaryRequest) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showError(message: "Cloudinary upload failed: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self?.showError(message: "Failed to upload image. Please try again.")
                }
                return
            }
            
            do {
                // Parse Cloudinary response
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let imageUrl = json["secure_url"] as? String {
                    print("Image uploaded successfully: \(imageUrl)")
                    
                    // Call backend API to save service details
                    self?.saveServiceToBackend(serviceName: serviceName, price: price, imageUrl: imageUrl)
                } else {
                    DispatchQueue.main.async {
                        self?.showError(message: "Failed to parse Cloudinary response.")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.showError(message: "Error parsing Cloudinary response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func saveServiceToBackend(serviceName: String, price: String, imageUrl: String) {
        guard let url = URL(string: "\(baseUrl)/salons/services") else {
            DispatchQueue.main.async {
                self.showError(message: "Invalid backend URL.")
            }
            return
        }
        
        let requestBody: [String: Any] = [
            "name": serviceName,
            "price": price,
            "serviceImage": imageUrl
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Add Authorization header
            if let authToken = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            } else {
                DispatchQueue.main.async {
                    self.showError(message: "Authorization token not found. Please log in again.")
                }
                return
            }
            
            request.httpBody = jsonData
            
            print("Request URL: \(url)")
            print("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showError(message: "Error saving service to backend: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        self.showError(message: "No response from server.")
                        return
                    }
                    
                    if !(200...299).contains(httpResponse.statusCode) {
                        let responseMessage = String(data: data ?? Data(), encoding: .utf8) ?? "No message"
                        print("Error Response Code: \(httpResponse.statusCode)")
                        print("Error Response Body: \(responseMessage)")
                        self.showError(message: "Failed to save service. Please try again.")
                        return
                    }
                    
                    print("Service added successfully to backend.")
                    self.showAlert = true
                    self.isServiceAdded = true
                }
            }.resume()
        } catch {
            DispatchQueue.main.async {
                self.showError(message: "Error encoding request body: \(error.localizedDescription)")
            }
        }
    }
    
    private func createMultipartBody(boundary: String, parameters: [String: String], filePathKey: String, imageData: Data, mimeType: String, fileName: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    func getProfile() {
        guard let url = URL(string: "\(baseUrl)/salons/profile") else {
            showError(message: "Invalid URL for profile.")
            return
        }

        NetworkManager.performRequest(url: url, viewModel: self) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    
                    let response = try JSONDecoder().decode(SalonResponse.self, from: data)
                    DispatchQueue.main.async {
                        if let salonData = response.salon {
                            AppDataManager.shared.saveSalon(salonData)
                            self?.salonDetails = salonData
                            self?.profileImageURL = salonData.mainPicture
                            print(salonData.name)
                            print("Profile fetched successfully")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.showError(message: "Failed to decode profile data: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if let nsError = error as? NSError,
                       let errorData = nsError.userInfo["data"] as? Data,
                       let errorResponse = String(data: errorData, encoding: .utf8) {
                        self?.showError(message: "Error fetching profile: \(errorResponse)")
                    } else {
                        self?.showError(message: "Error fetching profile: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func showError(message: String) {
        self.errorMessage = message
        self.showAlert = true
    }
    
    func registerSalon(salonName: String, email: String, password: String, address: String, openingTime: Date, closingTime: Date) {
        guard let currentLocation = LocationManager.shared.currentLocation else {
            showError(message: "Unable to fetch current location. Please check your location settings.")
            return
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let payload: [String: Any] = [
            "name": salonName,
            "email": email,
            "password": password,
            "address": address,
            "operatingHours": [
                "start": timeFormatter.string(from: openingTime),
                "end": timeFormatter.string(from: closingTime)
            ],
            "lat": currentLocation.latitude,
            "lon": currentLocation.longitude
        ]
        
        guard let url = URL(string: baseUrl + "/auth/salon/register") else {
            showError(message: "Invalid URL.")
            return
        }
        
        NetworkManager.performRequest(url: url, method: "POST", body: payload, viewModel: self) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.isRegistered = true
                    print("Salon registered successfully.")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showError(message: "Registration failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loginSalon(email: String, password: String) {
        guard let url = URL(string: "\(baseUrl)/auth/salon/login") else {
            showError(message: "Invalid URL")
            return
        }
        
        let payload: [String: Any] = ["email": email, "password": password]
        
        NetworkManager.performRequest(url: url, method: "POST", body: payload, viewModel: self) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(SalonResponse.self, from: data)
                    DispatchQueue.main.async {
                        if let data = response.salon, let token = response.token {
                            AppDataManager.shared.saveSalon(data)
                            AppDataManager.shared.saveLoginStatus(token: token)
                            self?.isLoggedIn = AppDataManager.shared.isLoggedIn()
                            print("Login successful.")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.showError(message: "Failed to parse login response: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showError(message: "Login failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func logOutSalon() {
        guard let url = URL(string: "\(baseUrl)/auth/salon/logout") else {
            showError(message: "Invalid Logout URL.")
            return
        }
        
        guard let salonId = AppDataManager.shared.getSalon()?.id else {
            showError(message: "Salon ID not found. Please log in again.")
            return
        }
        
        let payload: [String: Any] = ["salonId": salonId]
        
        NetworkManager.performRequest(url: url, method: "POST", body: payload, viewModel: self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    AppDataManager.shared.logout()
                    self?.isLoggedIn = AppDataManager.shared.isLoggedIn()
                    print("Salon logged out successfully.")
                case .failure(let error):
                    self?.showError(message: "Logout failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleUnauthorized() {
        AppDataManager.shared.logout()
        DispatchQueue.main.async {
            self.isLoggedIn = AppDataManager.shared.isLoggedIn()
            print("Session expired. Redirecting to login view.")
        }
    }
}
