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
// TODO: Handling inaccurate locations

class UserLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared: UserLocationService = UserLocationService()
    private let manager: CLLocationManager
    @Published var locationAuthorization = LocationAuthorizationStatus.denied

    override private init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }

    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
    }

    // FIXME: On first start of app causes crash beacause of nil value.
    var userLocation: CLLocation {
        manager.location!
    }

    var userLocation2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: manager.location?.coordinate.latitude ?? 60.192059,
            longitude: manager.location?.coordinate.longitude ?? 24.945831
        )
    }

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

    // TODO: Is this needed?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
         if let locationObj = locations.last {
         Helper.log(locationObj.horizontalAccuracy)
         userLocationObj = locationObj
         isLocationAccurate = locationObj.horizontalAccuracy < 500
         if BikeRentalService.shared.lastFetchAccurate == nil || !BikeRentalService.shared.lastFetchAccurate! && isLocationAccurate {
         BikeRentalService.shared.updateAll()
         }

         }
         */
    }
    private func toCoordinate2D(lat: Double, lon: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon
        )
    }
}

enum LocationAuthorizationStatus {
    case success
    case denied
}
