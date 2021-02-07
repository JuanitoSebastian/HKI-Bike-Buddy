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
        saveViewContext()
    }

    private func saveViewContext() {
        do {
            try viewContext.save()
        } catch {
            Helper.log("Failed to save ViewContext")
        }
    }
}
