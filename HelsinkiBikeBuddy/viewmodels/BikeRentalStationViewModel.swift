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

    @Published var bikeRentalStation: BikeRentalStation? {
        willSet {
            Helper.log("Updating stations to: \(newValue!)")
        }
    }

    let bikeRentalStorage = BikeRentalStationStorage.shared
    let userLocationManager = UserLocationManager.shared
    private var cancellable: AnyCancellable?

    init(
        stationId: String,
        bikeRentalStationPublisher: AnyPublisher<[String: BikeRentalStation], Never> =
            BikeRentalStationStorage.shared.bikeRentalStations.eraseToAnyPublisher()
    ) {
        cancellable = bikeRentalStationPublisher.sink { bikeRentalStations in
            self.bikeRentalStation = bikeRentalStations[stationId]
        }
    }

    var name: String {
        bikeRentalStation?.name ?? ""
    }

    var stationId: String {
        bikeRentalStation?.stationId ?? ""
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
        Int(bikeRentalStation!.spacesAvailable)
    }

    var bikes: Int {
        Int(bikeRentalStation!.bikesAvailable)
    }

    var totalSpaces: Int {
        spaces + bikes
    }

    var coordinates: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
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
        return dateFormatter.string(from: bikeRentalStation!.fetched)
    }

    func deleteStation() {
        bikeRentalStorage.deleteBikeRentalStation(bikeRentalStation!)
    }

    func incrementBikes() {
        bikeRentalStation?.bikesAvailable += 1
        bikeRentalStation?.spacesAvailable -= 1
        bikeRentalStorage.saveMoc()
    }

    func decrementBikes() {
        bikeRentalStation?.spacesAvailable += 1
        bikeRentalStation?.bikesAvailable -= 1
        bikeRentalStorage.saveMoc()
    }

}
