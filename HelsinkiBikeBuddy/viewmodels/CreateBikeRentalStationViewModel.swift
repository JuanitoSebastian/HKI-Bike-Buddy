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
    let bikeRentalStationSorage = BikeRentalStationStorage.shared
    let bikeRentalService = BikeRentalService.shared

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func createBikeRentalStop(name: String, stationId: String, lat: String, lon: String, favorite: Bool) {

        guard let latitude = Double(lat), let longitude = Double(lon) else { return }

        do {
            try BikeRentalStation.validateName(name)
            try BikeRentalStation.validateStationId(stationId)
            try BikeRentalStation.validateCoordinates(lat: latitude, lon: longitude)
        } catch {
            Helper.log("Failed to create Bike Rental Station: \(error)")
            return
        }

        bikeRentalStationSorage.createBikeRentalStation(
            name: name,
            stationId: stationId,
            lat: latitude,
            lon: longitude,
            spacesAvailable: Int.random(in: 0...15),
            bikesAvailable: Int.random(in: 0...15),
            allowDropoff: true,
            favorite: favorite,
            state: true
        )
    }

    func fetchStop(stationId: String) {
        bikeRentalService.fetchBikeRentalStation(stationId: stationId)
    }

    func fetchAll() {
        bikeRentalService.fetchAll()
    }
}
