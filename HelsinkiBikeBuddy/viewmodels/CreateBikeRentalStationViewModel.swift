//
//  BikeRentalStationCreatorViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import CoreData

class CreateBikeRentalStationViewModel {

    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func createBikeRentalStop(name: String, stationId: String, lat: String, lon: String) {
        let bikeRentalStation = BikeRentalStation(context: viewContext)
        bikeRentalStation.name = name
        bikeRentalStation.stationId = stationId
        bikeRentalStation.lat = Double(lat) ?? -1
        bikeRentalStation.lon = Double(lon) ?? -1
        do {
            try BikeRentalStation.validateBikeRentalStation(bikeRentalStation)
            Helper.saveViewContext(viewContext)
        } catch {
            Helper.log("Failed to create Bike Rental Station: \(error)")
            Helper.removeBikeRentalStation(bikeRentalStation: bikeRentalStation, viewContext: viewContext)
        }

    }
}
