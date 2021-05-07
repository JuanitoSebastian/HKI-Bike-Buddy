//
//  UserLocationManager.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.2.2021.
//

import Foundation
import CoreLocation
import MapKit

/// A class for accessing the location data of the system. This class listens to changes
/// in the location services authorization and the current location of the user and
/// relays this information to other parts of the application.
/// # Usage
/// Class is accessed via a singleton instance
/// ```
/// UserLocationService.shared
/// ```
/// # Testing
/// During testing the current location of the device and the location services authorization state
/// can be changed using the setUserLocation and setLocationAuthorization methods.
class UserLocationService: NSObject, ObservableObject {

    static let shared: UserLocationService = UserLocationService()

    @Published private(set) var locationAuthorization = LocationAuthorizationStatus.denied
    @Published private(set) var userLocation: CLLocation?

    private let manager: CLLocationManager
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

    /// Request location services authorization from the system. Calling this method
    /// triggers the "Allow HKI Bike Buddy to user your location?" alert.
    /// - *The alert is only shown once!* After calling this method the first time
    /// the alert will no longer be triggered and the user will have to enable location services
    /// form the settings of the device.
    func requestLocationServicesPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Starts frequent updating the user location
    func startUpdatingUserLocation() {
        Log.i("Starting user location udpates")
        manager.startUpdatingLocation()
    }

    /// Stops frequent updating of the user location
    func stopUpdatingUserLocation() {
        Log.i("Stopping user location updates")
        manager.stopUpdatingLocation()
    }

    /// Set the user location during testing
    func setUserLocation(location: CLLocation) {
        if operationMode == .testing {
            userLocation = location
        }
    }

    /// Set location authorization status during testing
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
