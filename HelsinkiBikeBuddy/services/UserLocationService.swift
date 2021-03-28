//
//  UserLocationManager.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.2.2021.
//

import Foundation
import CoreLocation
import MapKit

// TODO: Error handling for locations
class UserLocationService: NSObject, ObservableObject {

    // Singleton instance
    static let shared: UserLocationService = UserLocationService()

    @Published var locationAuthorization = LocationAuthorizationStatus.denied

    private let manager: CLLocationManager
    private let operationMode: OperationMode
    var testingLocation: CLLocation?

    override private init() {
        manager = CLLocationManager()
        #if DEBUG
        operationMode = Helper.isRunningTests() ? .testing : .normal
        #else
        operationMode = .normal
        #endif
        super.init()
        manager.delegate = self
    }

    /// Requests user to authorize location services
    func requestLocationServicesPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Returns the current CLLocation? obtained from CLLocationManager.
    /// If testing flag is found, the testingLocation is returned
    var userLocation: CLLocation? {
        #if DEBUG
        return operationMode == .testing ? testingLocation : manager.location
        #else
        return manager.location
        #endif
    }

    /// Returns the current CLLocation? obtained from CLLocationManager but converted to CLLocationCoordinate2D?
    /// If testing flag is found, the testingLocation is returned
    var userLocation2D: CLLocationCoordinate2D? {
        guard let location = userLocation else { return nil }
        return CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
}

// MARK: - CLLocationManagerDelegate
extension UserLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {

        case .restricted, .denied, .notDetermined:
            Log.i("Location services not permitted")
            locationAuthorization = .denied

        default:
            Log.i("Location services permitted")
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
