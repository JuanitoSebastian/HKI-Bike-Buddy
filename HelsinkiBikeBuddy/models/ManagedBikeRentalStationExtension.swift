//
//  BikeRentalStationExtension.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 8.2.2021.
//

import Foundation
import CoreData

// MARK: - Custom initializer
extension ManagedBikeRentalStation {
    convenience init(
        context: NSManagedObjectContext,
        stationId: String,
        name: String,
        lat: Double,
        lon: Double,
        state: Bool,
        allowDropff: Bool,
        spacesAvailable: Int64,
        bikesAvailable: Int64,
        fetched: Date
    ) {
        Log.i("Initiating ManagedBikeRentalStation: \(name) (\(stationId)")
        self.init(context: context)
        self.stationId = stationId
        self.id = UUID()
        self.name = name
        self.lat = lat
        self.lon = lon
        self.state = state
        self.allowDropoff = allowDropoff
        self.spacesAvailable = spacesAvailable
        self.bikesAvailable = bikesAvailable
        self.fetched = fetched
    }
}

// MARK: - RentalRentalStation
extension ManagedBikeRentalStation: RentalStation {
    var favourite: Bool {
        true
    }
}
