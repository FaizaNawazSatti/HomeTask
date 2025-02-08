//
//  TaskAssingmentTests.swift
//  TaskAssingmentTests
//
//  Created by Faiza Satti on 08/02/2025.
//

import XCTest
import CoreData
@testable import TaskAssingment

final class TaskAssingmentTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        
        let container = NSPersistentContainer(name: "GeofenceData")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType  // Use in-memory store
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load in-memory store: \(error!.localizedDescription)")
        }
        
        coreDataManager = CoreDataManager.shared
        coreDataManager.persistentContainer = container  // Inject test container
    }
    
    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }
    
    func testSaveGeofence() {
        let location = Location(id: "1", name: "Test Location", lat: 33.6, lon: 73.1, category: "Test")
        
        coreDataManager.saveGeofence(location: location, radius: 100, note: "Test Note")
        let geofences = coreDataManager.fetchGeofences()
        
        XCTAssertEqual(geofences.count, 1)
        XCTAssertEqual(geofences.first?.name, "Test Location")
        XCTAssertEqual(geofences.first?.radius, 100)
    }
    
    func testDeleteGeofence() {
        let location = Location(id: "2", name: "Delete Location", lat: 33.6, lon: 73.1, category: "Test")
        
        coreDataManager.saveGeofence(location: location, radius: 150, note: "To be deleted")
        var geofences = coreDataManager.fetchGeofences()
        XCTAssertEqual(geofences.count, 1)
        
        coreDataManager.deleteGeofence(geofence: geofences.first!)
        geofences = coreDataManager.fetchGeofences()
        XCTAssertEqual(geofences.count, 0)
    }
    
}
class LocationViewModelTests: XCTestCase {
    var viewModel: LocationViewModel!
    var mockAPIService: MockAPIService!
    var coreDataManager: CoreDataManager!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = LocationViewModel()
        viewModel.apiService = mockAPIService  // Inject mock API service

        let container = NSPersistentContainer(name: "GeofenceData")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType  // Use in-memory store
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load in-memory store: \(error!.localizedDescription)")
        }

        coreDataManager = CoreDataManager.shared
        coreDataManager.persistentContainer = container
        viewModel.coreDataManager = coreDataManager
    }

    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        coreDataManager = nil
        super.tearDown()
    }

    func testFetchLocations() {
        let expectation = self.expectation(description: "Fetch Locations")

        viewModel.fetchLocations {_ in 
            XCTAssertEqual(self.viewModel.locations.count, 2)
            XCTAssertEqual(self.viewModel.locations.first?.name, "Test Place")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testSaveAndLoadGeofence() {
        let location = Location(id: "1", name: "Test Place", lat: 33.6, lon: 73.1, category: "Park")
        viewModel.saveGeofence(location: location, radius: 100, note: "Geofence Note")

        let geofences = viewModel.loadGeofences()
        XCTAssertEqual(geofences.count, 1)
        XCTAssertEqual(geofences.first?.name, "Test Place")
        XCTAssertEqual(geofences.first?.radius, 100)
    }

    func testDeleteGeofence() {
        let location = Location(id: "2", name: "Delete Me", lat: 33.7, lon: 73.2, category: "Mall")
        viewModel.saveGeofence(location: location, radius: 50, note: "Temporary")

        var geofences = viewModel.loadGeofences()
        XCTAssertEqual(geofences.count, 1)

        viewModel.deleteGeofence(geofence: geofences.first!)
        geofences = viewModel.loadGeofences()
        XCTAssertEqual(geofences.count, 0)
    }
}
