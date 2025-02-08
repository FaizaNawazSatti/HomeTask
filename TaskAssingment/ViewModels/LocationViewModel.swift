//
//  LocationViewModel.swift
//  TaskAssingment
//
//  Created by Faiza Satti on 08/02/2025.
//

import Foundation
class LocationViewModel {
    var locations: [Location] = []
    var apiService = APIService()
    var coreDataManager = CoreDataManager.shared
    
    func fetchLocations(completion: @escaping (Result<Void, Error>) -> Void) {
        apiService.fetchLocations { result in
            switch result {
            case .success(let locations):
                self.locations = locations
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func saveGeofence(location: Location, radius: Double, note: String) {
        coreDataManager.saveGeofence(location: location, radius: radius, note: note)
    }
    
    func loadGeofences() -> [GeofenceEntity] {
        return coreDataManager.fetchGeofences()
    }
    
    func deleteGeofence(geofence: GeofenceEntity) {
        coreDataManager.deleteGeofence(geofence: geofence)
    }
}
