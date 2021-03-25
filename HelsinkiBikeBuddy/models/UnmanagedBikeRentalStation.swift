//
//  UnmanagedBikeRentalStation.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.2.2021.
//

import Foundation

class UnmanagedBikeRentalStation {

    var stationId: String
    var name: String
    var allowDropoff: Bool
    var bikesAvailable: Int64
    var fetched: Date
    var lat: Double
    var lon: Double
    var spacesAvailable: Int64
    var state: Bool

    internal init(
        stationId: String,
        name: String,
        allowDropoff: Bool,
        bikesAvailable: Int64,
        fetched: Date,
        lat: Double,
        lon: Double,
        spacesAvailable: Int64,
        state: Bool
    ) {
        self.stationId = stationId
        self.name = name
        self.allowDropoff = allowDropoff
        self.bikesAvailable = bikesAvailable
        self.fetched = fetched
        self.lat = lat
        self.lon = lon
        self.spacesAvailable = spacesAvailable
        self.state = state
    }

}

// MARK: - RentalStation
extension UnmanagedBikeRentalStation: RentalStation {
    var favourite: Bool {
        false
    }
}

// MARK: - Identifiable
extension UnmanagedBikeRentalStation: Identifiable {
    var id: String {
        stationId
    }
}
