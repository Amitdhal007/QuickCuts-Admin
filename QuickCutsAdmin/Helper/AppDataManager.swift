//
//  AppDataManager.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 24/11/24.
//

import Foundation

class AppDataManager {
    static let shared = AppDataManager() // Singleton instance

    private let userDefaults = UserDefaults.standard

    // Keys for UserDefaults
    private let authTokenKey = "authToken"
    private let isLoggedInKey = "isLoggedIn"
    private let salonDataKey = "salonData"

    // MARK: - Authentication

    /// Save login status and token
    func saveLoginStatus(token: String) {
        userDefaults.set(token, forKey: authTokenKey)
        userDefaults.set(true, forKey: isLoggedInKey)
    }

    /// Check if the user is logged in
    func isLoggedIn() -> Bool {
        return userDefaults.bool(forKey: isLoggedInKey)
    }

    /// Logout and clear all user-related data
    func logout() {
        userDefaults.removeObject(forKey: authTokenKey)
        userDefaults.set(false, forKey: isLoggedInKey)
        userDefaults.removeObject(forKey: salonDataKey)
    }

    /// Get the saved authentication token
    func getAuthToken() -> String? {
        return userDefaults.string(forKey: authTokenKey)
    }

    // MARK: - CRUD Operations for Salon

    /// Save a salon object to UserDefaults
    func saveSalon(_ salon: Salon) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(salon)
            userDefaults.set(data, forKey: salonDataKey)
        } catch {
            print("Error encoding salon data: \(error.localizedDescription)")
        }
    }

    /// Retrieve the saved salon object from UserDefaults
    func getSalon() -> Salon? {
        guard let data = userDefaults.data(forKey: salonDataKey) else { return nil }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Salon.self, from: data)
        } catch {
            print("Error decoding salon data: \(error.localizedDescription)")
            return nil
        }
    }

    /// Update specific fields in the saved salon object
    func updateSalon(updates: [String: Any]) {
        guard var existingSalon = getSalon() else { return }
        do {
            // Convert existing salon to dictionary for updates
            let encoder = JSONEncoder()
            let data = try encoder.encode(existingSalon)
            var salonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]

            // Apply updates
            updates.forEach { key, value in
                salonDict[key] = value
            }

            // Convert back to Salon object and save
            let updatedData = try JSONSerialization.data(withJSONObject: salonDict, options: [])
            let decoder = JSONDecoder()
            existingSalon = try decoder.decode(Salon.self, from: updatedData)
            saveSalon(existingSalon)
        } catch {
            print("Error updating salon data: \(error.localizedDescription)")
        }
    }

    /// Delete the saved salon data
    func deleteSalon() {
        userDefaults.removeObject(forKey: salonDataKey)
    }
}

