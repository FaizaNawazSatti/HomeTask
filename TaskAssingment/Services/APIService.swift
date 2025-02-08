//
//  APIService.swift
//  TaskAssingment
//
//  Created by Faiza Satti on 08/02/2025.
//

import Foundation
class APIService {

    func fetchLocations(completion: @escaping (Result<[Location], Error>) -> Void) {
        let urlString = "https://overpass-api.de/api/interpreter?data=[out:json];node(33.5,72.9,33.7,73.2);out body;"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(OverpassResponse.self, from: data)

                // Filter only Rawalpindi locations
                let locations = decodedResponse.elements.compactMap { element -> Location? in
                    guard let lat = element.lat, let lon = element.lon,
                          let name = element.tags?["name:en"] ?? element.tags?["name"] else {
                        return nil
                    }

                    // Ensure it's inside Rawalpindi
                    let isRawalpindi = element.tags?["addr:city:en"] == "Rawalpindi" || element.tags?["place"] == "city"
                    
                    return isRawalpindi ? Location(id: "\(element.id)", name: name, lat: lat, lon: lon, category: "place") : nil
                }

                completion(.success(locations))
            } catch {
                print("JSON Parsing Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }


}
class MockAPIService: APIService {
    override func fetchLocations(completion: @escaping (Result<[Location], Error>) -> Void) {
        let mockLocations = [
            Location(id: "1", name: "Test Place", lat: 33.6, lon: 73.1, category: "Park"),
            Location(id: "2", name: "Another Place", lat: 33.7, lon: 73.2, category: "Mall")
        ]
        completion(.success(mockLocations))
    }
}
