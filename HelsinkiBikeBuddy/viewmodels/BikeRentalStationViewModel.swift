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

    init(viewContext: NSManagedObjectContext, bikeRentalStation: BikeRentalStation) {
        self.viewContext = viewContext
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

    func distanceInMeters(comparison: CLLocation) -> String {
        let distD: Double = Double(coordinates.distance(from: comparison)).rounded()
        return "\(distD)m away"
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
