//
//  UserLocationManager.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.2.2021.
//

import Foundation
import CoreLocation
import MapKit

class UserLocationService: NSObject, ObservableObject {

    // Singleton instance
    static let shared: UserLocationService = UserLocationService()

    @Published private(set) var locationAuthorization = LocationAuthorizationStatus.denied
    @Published private(set) var userLocation: CLLocation?

    let manager: CLLocationManager
    private let operationMode: OperationMode
    var testingLocation: CLLocation?

    override private init() {
        manager = CLLocationManager()
        #if DEBUG
        operationMode = Helper.isRunningTests() ? .testing : .normal
        super.init()
        if operationMode == .normal { manager.delegate = self }
        #else
        operationMode = .normal
        super.init()
        manager.delegate = self
        #endif
    }

    /// Returns the current CLLocation? converted to CLLocationCoordinate2D?
    var userLocation2D: CLLocationCoordinate2D? {
        guard let location = userLocation else { return nil }
        return location.coordinate
    }
}

// MARK: - Functions
extension UserLocationService {

    /// Requests user to authorize location services
    func requestLocationServicesPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingUserLocation() {
        Log.i("Starting user location udpates")
        manager.startUpdatingLocation()
    }

    func stopUpdatingUserLocation() {
        Log.i("Stopping user location updates")
        manager.stopUpdatingLocation()
    }

    func setUserLocation(location: CLLocation) {
        if operationMode == .testing {
            userLocation = location
        }
    }

    func setLocationAuthorization(authorization: LocationAuthorizationStatus) {
        if operationMode == .testing {
            locationAuthorization = authorization
        }
    }
}

// MARK: - CLLocationManagerDelegate
/// Delegate responds to location events such as changes of location authorization and
/// changes in the current location of the user. Further information can be found here:
/// https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate
extension UserLocationService: CLLocationManagerDelegate {

    /// Called when manager receives new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if operationMode == .testing { return }
        guard let currentLocation = locations.first else {
            Log.w("Found nil when unwrapping user location")
            return
        }

        // Checking for Null Island
        if currentLocation.coordinate.latitude == 0 && currentLocation.coordinate.longitude == 0 {
            Log.w("Found Null Island in CLLocationManager coordinate")
            return
        }

        Log.i("Setting new userLocation")
        userLocation = currentLocation
    }

    /// Called when location authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {

        case .restricted, .denied, .notDetermined:
            Log.i("Location services not permitted")
            manager.stopMonitoringSignificantLocationChanges()
            locationAuthorization = .denied

        default:
            Log.i("Location services permitted")
            manager.startMonitoringSignificantLocationChanges()
            locationAuthorization = .success

        }
    }
}

// MARK: - ENUMS
extension UserLocationService {
    enum LocationAuthorizationStatus {
        case success
        case denied
    }

    enum OperationMode {
        case normal
        case testing
    }
}
