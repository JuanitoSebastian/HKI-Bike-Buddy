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

class UserLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared: UserLocationManager = UserLocationManager()
    private let manager: CLLocationManager

    @Published var userLocationObj: CLLocation?
    @Published var isLocationAccurate: Bool = false
    @Published var locationAuthorization: LocationAuthorizationStatus = LocationAuthorizationStatus.denied

    override private init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }

    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
    }

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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationObj = locations.last {
            Helper.log(locationObj.horizontalAccuracy)
            userLocationObj = locationObj
            isLocationAccurate = locationObj.horizontalAccuracy < 500
            if BikeRentalService.shared.lastFetchAccurate == nil || !BikeRentalService.shared.lastFetchAccurate! && isLocationAccurate {
                BikeRentalService.shared.updateAll()
            }
        }
    }

    func getTravelTimeFromUserLocation(destinationLat: Double, destinationLon: Double, completition: @escaping (_ time: TimeInterval?) -> Void) {
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation2D))
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: toCoordinate2D(lat: destinationLat, lon: destinationLon)))
        directionsRequest.transportType = .walking
        directionsRequest.requestsAlternateRoutes = true

        let directions = MKDirections(request: directionsRequest)
        directions.calculate {(res, error) -> Void in
            guard let res = res else {
                if let error = error {
                    Helper.log("Error calculating route: \(error)")
                }
                return
            }

            if res.routes.count > 0 {
                let route = res.routes[0]
                completition(route.expectedTravelTime)
            }
        }
        completition(nil)
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
