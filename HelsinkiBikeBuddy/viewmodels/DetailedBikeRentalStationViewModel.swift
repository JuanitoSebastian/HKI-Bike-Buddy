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

    static let shared = DetailedBikeRentalStationViewModel()

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
        get {
            return bikeRentalStation?.favorite ?? false
        }
        set(newVal) {
            if newVal {
                guard let managedBikeRentalStation
                        = bikeRentalStorage.toManagedStation(unmanaged: bikeRentalStation!) else { return }
                self.bikeRentalStation = managedBikeRentalStation
                BikeRentalService.shared.fetchNearbyStations()
            } else {
                guard let unmanagedBikeRentalStation
                        = bikeRentalStorage.toUnmanagedStation(managed: bikeRentalStation!) else { return }
                self.bikeRentalStation = unmanagedBikeRentalStation
                BikeRentalService.shared.fetchNearbyStations()
            }
        }
    }

    func distanceInMeters() -> String {
        var distanceDouble = Double(coordinates.distance(from: userLocationManager.userLocation)).rounded()
        if distanceDouble >= 1000 {
            distanceDouble /= 1000
            return "\(String(distanceDouble))km"
        }
        return "\(String(distanceDouble))m"
    }

    var distanceToShow: String {
        "\(distanceInMeters()) away 🚶"
    }
}
