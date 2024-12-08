//
//  LocationManager.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private var locationManager: CLLocationManager = CLLocationManager()

    @Published var currentLocation: CLLocationCoordinate2D?

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // Request location access
        locationManager.startUpdatingLocation()
    }

    // CLLocationManagerDelegate method to update location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
    }
}
