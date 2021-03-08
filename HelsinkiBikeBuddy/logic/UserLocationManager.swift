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

class UserLocationManager: ObservableObject {

    static let shared: UserLocationManager = UserLocationManager()
    private let manager: CLLocationManager

    private init() {
        manager = CLLocationManager()
        requestPermissions()
    }

    func requestPermissions() {
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
    }

    var userLocation: CLLocation {
        manager.location ?? CLLocation(latitude: 60.192059, longitude: 24.945831)
    }

    var userLocation2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: manager.location?.coordinate.latitude ?? 60.192059,
            longitude: manager.location?.coordinate.longitude ?? 24.945831
        )
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
