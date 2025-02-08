//
//  LocationManager.swift
//  TaskAssingment
//
//  Created by Faiza Satti on 08/02/2025.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()

    override private init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocationPermission(completion: @escaping (Bool) -> Void) {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            
            completion(false)
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            completion(true)
        @unknown default:
            completion(false)
        }
    }

}
