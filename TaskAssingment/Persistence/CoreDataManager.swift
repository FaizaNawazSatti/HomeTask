//
//  CoreDataManager.swift
//  TaskAssingment
//
//  Created by Faiza Satti on 08/02/2025.
//

import Foundation
import CoreData
class CoreDataManager {
    static let shared = CoreDataManager()
    var persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "GeofenceData")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    func saveGeofence(location: Location, radius: Double, note: String) {
        let context = persistentContainer.viewContext
        let geofence = GeofenceEntity(context: context)
        geofence.id = location.id
        geofence.name = location.name
        geofence.latitude = location.lat
        geofence.longitude = location.lon
        geofence.radius = radius
        geofence.note = note
        
        do {
            try context.save()
        } catch {
            print("Failed to save geofence: \(error)")
        }
    }
    
    
    func fetchGeofences() -> [GeofenceEntity] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<GeofenceEntity> = GeofenceEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch geofences: \(error)")
            return []
        }
    }
    
    func deleteGeofence(geofence: GeofenceEntity) {
        let context = persistentContainer.viewContext
        context.delete(geofence)
        do {
            try context.save()
        } catch {
            print("Failed to delete geofence: \(error)")
        }
    }
}
