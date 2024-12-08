//
//  SlonModel.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 22/11/24.
//

import Foundation

// MARK: - SalonResponse
struct SalonResponse: Codable {
    let success: Bool?
    let token: String?
    let salon: Salon?
}

// MARK: - DataClass
struct Salon: Codable {
    let location: Location?
    let operatingHours: OperatingHours?
    let id, name, email, address: String?
    let mainPicture: String?
    let averageRating: Int?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case location, operatingHours
        case id = "_id"
        case name, email, address, mainPicture, averageRating, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - Location
struct Location: Codable {
    let type: String?
    let coordinates: [Double]?
}

// MARK: - OperatingHours
struct OperatingHours: Codable {
    let start, end: String?
}
