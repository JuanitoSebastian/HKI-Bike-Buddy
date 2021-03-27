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
import UIKit

class BikeRentalStationViewModel: ObservableObject {

    @Published var bikeRentalStation: RentalStation
    @Published var favoriteStatus: Bool
    private var toggleTriggered: Bool

    let bikeRentalStorage = BikeRentalStationStore.shared
    let userLocationManager = UserLocationService.shared

    init(bikeRentalStation: RentalStation) {
        self.bikeRentalStation = bikeRentalStation
        self.favoriteStatus = bikeRentalStation.favourite
        self.toggleTriggered = false
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

    var state: BikeRentalStationViewState {
        return bikeRentalStation.state ? .normal : .unavailable
    }

    /**
     Toggles the favourite state of the bikeRentalStation
     */
    func toggleFavourite() {
        if toggleTriggered { return }
        toggleTriggered = true

        favoriteStatus.toggle()

        if bikeRentalStation.favourite {
            // Wait for the heart to turn grey
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                BikeRentalStationStore.shared.unfavouriteStation(rentalStation: self.bikeRentalStation)
                self.toggleTriggered = false
            }
        } else {
            BikeRentalStationStore.shared.favouriteStation(rentalStation: bikeRentalStation)
            toggleTriggered = false
        }
    }

    func distanceInMeters() -> String {
        guard let userLocation = UserLocationService.shared.userLocation else {
            return "User location unavailbale"
        }
        var distanceDouble = Int(
            Helper.roundToNearest(
                coordinates.distance(from: userLocation), toNearest: 20
            )
        )

        if distanceDouble >= 1000 {
            distanceDouble /= 1000
            return "\(String(distanceDouble)) km"
        }

        return "\(String(distanceDouble)) m"
    }

    var fetched: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: bikeRentalStation.fetched)
    }
}

enum BikeRentalStationViewState {
    case normal
    case unavailable
}
