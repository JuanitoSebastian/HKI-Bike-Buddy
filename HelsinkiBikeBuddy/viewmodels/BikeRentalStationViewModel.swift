//
//  BikeRentalStationViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import CoreData
import CoreLocation

class BikeRentalStationViewModel {

    let viewContext: NSManagedObjectContext
    let bikeRentalStation: BikeRentalStation
    let userLocationManager: UserLocationManager

    init(
        viewContext: NSManagedObjectContext,
        bikeRentalStation: BikeRentalStation,
        userLocationManager: UserLocationManager
    ) {
        self.viewContext = viewContext
        self.bikeRentalStation = bikeRentalStation
        self.userLocationManager = userLocationManager
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
        Helper.log(bikeRentalStation.fetched)
        return dateFormatter.string(from: bikeRentalStation.fetched)
    }

    func deleteStation() {
        Helper.removeBikeRentalStation(bikeRentalStation: bikeRentalStation, viewContext: viewContext)
        Helper.saveViewContext(viewContext)
    }

    func incrementBikes() {
        bikeRentalStation.bikesAvailable += 1
        bikeRentalStation.spacesAvailable -= 1
        Helper.saveViewContext(viewContext)
    }

    func decrementBikes() {
        bikeRentalStation.spacesAvailable += 1
        bikeRentalStation.bikesAvailable -= 1
        Helper.saveViewContext(viewContext)
    }

}
