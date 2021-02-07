//
//  BikeRentalStationViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import CoreData

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

    func deleteStation() {
        Helper.removeBikeRentalStation(bikeRentalStation: bikeRentalStation, viewContext: viewContext)
        Helper.saveViewContext(viewContext)
    }

}
