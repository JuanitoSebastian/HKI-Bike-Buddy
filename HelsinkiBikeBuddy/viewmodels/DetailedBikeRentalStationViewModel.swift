//
//  DetailedBikeRentalStationViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 20.2.2021.
//

import Foundation
import CoreLocation

class DetailedBikeRentalStationViewModel: ObservableObject {

    @Published var bikeRentalStation: RentalStation?

    let bikeRentalStorage = BikeRentalStationStorage.shared
    let userLocationManager = UserLocationManager.shared

    init(bikeRentalStation: RentalStation) {
        self.bikeRentalStation = bikeRentalStation
    }

    var name: String {
        bikeRentalStation?.name ?? "Unavailable"
    }

    var stationId: String {
        bikeRentalStation?.stationId ?? "-1"
    }

    var lat: Double {
        bikeRentalStation?.lat ?? -1
    }

    var lon: Double {
        bikeRentalStation?.lon ?? -1
    }

    var allowDropOff: Bool {
        bikeRentalStation?.allowDropoff ?? false
    }

    var spaces: Int {
        Int(bikeRentalStation?.spacesAvailable ?? -1)
    }

    var bikes: Int {
        Int(bikeRentalStation?.bikesAvailable ?? -1)
    }

    var totalSpaces: Int {
        spaces + bikes
    }

    var coordinates: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

    var favorite: Bool {
        return true
    }

    func distanceInMeters() -> String {
        var distanceDouble = Int(
            Helper.roundToNearest(
                coordinates.distance(from: userLocationManager.userLocation), toNearest: 20
            )
        )

        if distanceDouble >= 1000 {
            distanceDouble /= 1000
            return "\(String(distanceDouble)) km"
        }

        return "\(String(distanceDouble)) m"
    }

    var distanceToShow: String {
        "\(distanceInMeters()) away 🚶"
    }
}
