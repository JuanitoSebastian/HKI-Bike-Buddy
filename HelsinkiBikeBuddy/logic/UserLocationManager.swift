//
//  UserLocationManager.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.2.2021.
//

import Foundation
import CoreLocation

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
}
