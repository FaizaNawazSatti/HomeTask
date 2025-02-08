//
//  ViewController.swift
//  TaskAssingment
//
//  Created by Faiza Satti on 08/02/2025.
//

import UIKit
import MapKit
import UserNotifications
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let mapView = MKMapView()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let locationManager = CLLocationManager()
    let viewModel = LocationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupActivityIndicator()
        LocationManager.shared.requestLocationPermission { granted in
            if !granted {
                self.showAlert(title: "Permission Denied", message: "Please enable location permissions in Settings to use geofencing.")
            }
        }
        checkLocationPermission()
        loadLocations()
        loadSavedGeofences()
    }
    
    func setupMapView() {
        mapView.frame = view.bounds
        mapView.delegate = self
        view.addSubview(mapView)
        zoomToRawalpindi(mapView: mapView)
    }
    func setupActivityIndicator() {
        activityIndicator.center = view.center
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    func checkLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    func zoomToRawalpindi(mapView: MKMapView) {
        let rawalpindiCoordinates = CLLocationCoordinate2D(latitude: 33.5914237, longitude: 73.0535122)
        
        
        let region = MKCoordinateRegion(center: rawalpindiCoordinates,
                                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        
        mapView.setRegion(region, animated: true)
    }
    func loadLocations() {
        activityIndicator.startAnimating()
        viewModel.fetchLocations { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                switch result {
                case .success:
                    self.displayAnnotations()
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Failed to fetch locations: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadSavedGeofences() {
        let savedGeofences = viewModel.loadGeofences()
        for geofence in savedGeofences {
            let annotation = MKPointAnnotation()
            annotation.title = geofence.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: geofence.latitude, longitude: geofence.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    func displayAnnotations() {
        for location in viewModel.locations {
            let annotation = MKPointAnnotation()
            annotation.title = location.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        let alert = UIAlertController(title: "Set Geofence", message: "Enter radius:", preferredStyle: .alert)
        alert.addTextField { textField in textField.keyboardType = .numberPad }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            if let radiusText = alert.textFields?.first?.text, let radius = Double(radiusText) {
                self.setupGeofence(at: annotation.coordinate, radius: radius)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func setupGeofence(at coordinate: CLLocationCoordinate2D, radius: Double) {
        let region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: UUID().uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
        // Fetch location details (name, etc.) from `locations` list or use default values
        if let location = viewModel.locations.first(where: {
            $0.lat == coordinate.latitude && $0.lon == coordinate.longitude
        }) {
            viewModel.saveGeofence(location: location, radius: radius, note: "Your's visited place")
        }
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region is CLCircularRegion else { return }
        
        let title: String
        let body: String
        
        if state == .inside {
            title = "Geofence Entered"
            body = "You entered the geofence at \(region.identifier)"
        } else if state == .outside {
            title = "Geofence Exited"
            body = "You exited the geofence at \(region.identifier)"
        } else {
            return
        }
        
        sendGeofenceNotification(title: title, body: body)
    }
    func sendGeofenceNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
}

