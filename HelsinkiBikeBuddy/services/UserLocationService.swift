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

    static let shared: UserLocationService = UserLocationService()
    private let manager: CLLocationManager
    @Published var locationAuthorization = LocationAuthorizationStatus.denied
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

    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
    }

    var userLocation: CLLocation? {
        #if DEBUG
        return operationMode == .testing ? testingLocation : manager.location
        #else
        return manager.location
        #endif
    }

    var userLocation2D: CLLocationCoordinate2D? {
        guard let location = userLocation else { return nil }
        return CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }

    private func toCoordinate2D(lat: Double, lon: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon
        )
    }
}

// MARK: - CLLocationManagerDelegate
extension UserLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {

        case .restricted, .denied, .notDetermined:
            Helper.log("Location access is not permitted")
            locationAuthorization = .denied

        default:
            Helper.log("Location access permitted!")
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
