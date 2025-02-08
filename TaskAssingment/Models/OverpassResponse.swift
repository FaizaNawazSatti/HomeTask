//
//  OverpassResponse.swift
//  TaskAssingment
//
//  Created by Faiza Satti on 08/02/2025.
//

import Foundation
struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

struct OverpassElement: Codable {
    let id: Int
        let lat: Double?
        let lon: Double?
        let tags: [String: String]?
}
