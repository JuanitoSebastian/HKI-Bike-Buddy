//
//  BikeRentalService.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 12.2.2021.
//

import Foundation

class BikeRentalService {

    let bikeRentalStationStore = BikeRentalStationStorage.shared

    func updateStations() {
        for bikeRentalStation in bikeRentalStationStore.bikeRentalStations.value.values {
            bikeRentalStation.fetched = Date()

            let total = Int64(bikeRentalStation.totalCapacity)

            bikeRentalStation.bikesAvailable = Int64.random(in: 0...total)
            bikeRentalStation.spacesAvailable = total - bikeRentalStation.bikesAvailable

        }
        bikeRentalStationStore.saveMoc()
    }
}
