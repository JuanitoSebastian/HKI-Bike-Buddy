//
//  BikeRentalStationViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import CoreData
import CoreLocation
import Combine

class BikeRentalStationViewModel: ObservableObject {

    @Published var bikeRentalStation: RentalStation
    @Published var walkingTime: String?
    @Published var state: BikeRentalStationViewState = BikeRentalStationViewState.normal

    let bikeRentalStorage = BikeRentalStationStorage.shared
    let userLocationManager = UserLocationManager.shared

    init(bikeRentalStation: RentalStation) {
        self.bikeRentalStation = bikeRentalStation
    }

    var name: String {
        bikeRentalStation.name
    }

    var stationId: String {
        bikeRentalStation.stationId
    }

    var lat: Double {
        bikeRentalStation.lat
    }

    var lon: Double {
        bikeRentalStation.lon
    }

    var allowDropOff: Bool {
        bikeRentalStation.allowDropoff
    }

    var spaces: Int {
        Int(bikeRentalStation.spacesAvailable)
    }

    var bikes: Int {
        Int(bikeRentalStation.bikesAvailable)
    }

    var totalSpaces: Int {
        spaces + bikes
    }

    var coordinates: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

    var favorite: Bool {
        get {
            return bikeRentalStation.favorite
        }
        set(newVal) {
            if newVal {
                guard let managedBikeRentalStation
                        = bikeRentalStorage.toManagedStation(unmanaged: bikeRentalStation) else { return }
                self.bikeRentalStation = managedBikeRentalStation
                BikeRentalService.shared.fetchNearbyStations()
            } else {
                guard let unmanagedBikeRentalStation
                        = bikeRentalStorage.toUnmanagedStation(managed: bikeRentalStation) else { return }
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

    var fetched: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: bikeRentalStation.fetched)
    }

    func getWalkingTime() {
        userLocationManager.getTravelTimeFromUserLocation(destinationLat: lat, destinationLon: lon, completition: { res in
            guard let res = res else { return }
            DispatchQueue.main.async {
                self.walkingTime = String(res)
            }
        })
    }

    var distanceToShow: String {
        if walkingTime == nil {
            return "\(distanceInMeters()) away 🚶"
        }
        return "\(walkingTime!) second walk away 🚶"
    }
}

enum BikeRentalStationViewState {
    case normal
    case unavailable
}
