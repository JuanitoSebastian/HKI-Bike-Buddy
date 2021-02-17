//
//  UnmanagedBikeRentalStation.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.2.2021.
//

import Foundation
import CoreLocation

class UnmanagedBikeRentalStation: RentalStation {

    internal init(
        stationId: String,
        name: String,
        allowDropoff: Bool,
        bikesAvailable: Int64,
        favorite: Bool,
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
        self.favorite = favorite
        self.fetched = fetched
        self.lat = lat
        self.lon = lon
        self.spacesAvailable = spacesAvailable
        self.state = state
    }

    var stationId: String
    var name: String
    var allowDropoff: Bool
    var bikesAvailable: Int64
    var favorite: Bool
    var fetched: Date
    var lat: Double
    var lon: Double
    var spacesAvailable: Int64
    var state: Bool

    var location: CLLocation {
        return CLLocation(latitude: lat, longitude: lon)
    }

    var totalCapacity: Int {
        Int(spacesAvailable + bikesAvailable)
    }

    public var id: String {
        stationId
    }

    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }

}
