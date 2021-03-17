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

    let bikeRentalStorage = BikeRentalStationStorage.shared
    let userLocationManager = UserLocationManager.shared

    init(bikeRentalStation: RentalStation) {
        self.bikeRentalStation = bikeRentalStation
        self.favoriteStatus = bikeRentalStation.favorite
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

    var state: BikeRentalStationViewState {
        return bikeRentalStation.state ? .normal : .unavailable
    }

    var grayScaleAmount: Double {
        switch state {
        case .unavailable: return 1
        default: return 0
        }
    }

    var blurAmount: CGFloat {
        switch state {
        case .unavailable: return 2
        default: return 0
        }
    }

    func toggleFav() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        favoriteStatus = !favoriteStatus
        if bikeRentalStation.favorite {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
                guard let unmanagedBikeRentalStation = self.bikeRentalStorage.toUnmanagedStation(managed: self.bikeRentalStation) else { return }
                self.bikeRentalStation = unmanagedBikeRentalStation
                BikeRentalService.shared.fetchNearbyStations()
            }
        } else {
            guard let managedBikeRentalStation = self.bikeRentalStorage.toManagedStation(unmanaged: self.bikeRentalStation) else { return }
            self.bikeRentalStation = managedBikeRentalStation
            BikeRentalService.shared.fetchNearbyStations()
        }
    }

    func distanceInMeters() -> String {
        var distanceDouble = Int(Helper.roundToNearest(coordinates.distance(from: userLocationManager.userLocation), toNearest: 20))
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
