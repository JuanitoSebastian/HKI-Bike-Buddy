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

        let latitude: Double = Double(lat) ?? 0
        let longitude: Double = Double(lon) ?? 0

        do {
            try BikeRentalStation.validateName(name)
            try BikeRentalStation.validateStationId(stationId)
            try BikeRentalStation.validateCoordinates(lat: latitude, lon: longitude)
            let bikeRentalStation = BikeRentalStation(context: viewContext)
            bikeRentalStation.name = name
            bikeRentalStation.stationId = stationId
            bikeRentalStation.lat = latitude
            bikeRentalStation.lon = longitude
            bikeRentalStation.fetched = Date()
            bikeRentalStation.allowDropoff = true
            bikeRentalStation.spacesAvailable = Int64.random(in: 0...50)
            bikeRentalStation.bikesAvailable = Int64.random(in: 0...50)
            Helper.saveViewContext(viewContext)
        } catch {
            Helper.log("Failed to create Bike Rental Station: \(error)")
        }

    }
}
