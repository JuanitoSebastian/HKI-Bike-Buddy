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

    let bikeRentalStorage = BikeRentalStationStorage.shared
    let userLocationManager = UserLocationManager.shared

    init(bikeRentalStation: RentalStation) {
        self.bikeRentalStation = bikeRentalStation
        self.favoriteStatus = bikeRentalStation.favorite
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

        if bikeRentalStation.favorite {
            // Wait for the heart to turn grey
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                BikeRentalStationStorage.shared.unfavouriteStation(rentalStation: self.bikeRentalStation)
                self.toggleTriggered = false
            }
        } else {
            BikeRentalStationStorage.shared.favouriteStation(rentalStation: bikeRentalStation)
            toggleTriggered = false
        }
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
