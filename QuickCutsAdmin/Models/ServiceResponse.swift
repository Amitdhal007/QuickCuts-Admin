//
//  ServiceResponse.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 25/11/24.
//

import Foundation

// Model for top-level response
struct ServiceResponse: Codable {
    let success: Bool?
    let data: [Service]?
}

// Model for individual service
struct Service: Codable {
    let id: String?
    let name: String?
    let price: Int?
    let serviceImage: String?
    let salon: String?
    let createdAt: String?
    let updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case price
        case serviceImage
        case salon
        case createdAt
        case updatedAt
        case v = "__v"
    }
}
