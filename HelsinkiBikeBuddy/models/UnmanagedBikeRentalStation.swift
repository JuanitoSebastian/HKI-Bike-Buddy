//
//  UnmanagedBikeRentalStation.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.2.2021.
//

import Foundation
import CoreData

/// A bike rental station that is not saved to persistent store
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

    init(
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
        Log.i("Init of UnmanagedBikeRentalStation: \(name) (\(stationId))")
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
    // swiftlint:disable force_cast
    init?(apiResultMapOptional: [String: Any?]?) {
        guard let apiResultMap = apiResultMapOptional else {
            Log.d("Found nil when unwrapping apiResultMap")
            return nil
        }
        guard let fetchedStationId = apiResultMap["stationId"] as! String?,
              let fetchedName = apiResultMap["name"] as! String?,
              let fetchedBikesAvailable = apiResultMap["bikesAvailable"] as! Int?,
              let fetchedSpacesAvailable = apiResultMap["spacesAvailable"] as! Int?,
              let fetchedLat = apiResultMap["lat"] as! Double?,
              let fetchedLon = apiResultMap["lon"] as! Double?,
              let fetchedAllowDropoff = apiResultMap["allowDropoff"] as! Bool?,
              let fetchedState = apiResultMap["state"] as! String? else {
            Log.d("Found nil when unwrapping one of apiResultMap values")
            return nil
        }
        self.stationId = fetchedStationId
        self.name = fetchedName
        self.allowDropoff = fetchedAllowDropoff
        self.bikesAvailable = Int64(fetchedBikesAvailable)
        self.fetched = Date()
        self.lat = fetchedLat
        self.lon = fetchedLon
        self.spacesAvailable = Int64(fetchedSpacesAvailable)
        self.state = Helper.parseStateString(fetchedState)
        Log.i("Init of UnmanagedBikeRentalStation: \(name) (\(stationId))")
    }
    // swiftlint:enable force_cast
    deinit {
        Log.i("Deinit of UnmanagedBikeRentalStation: \(name) (\(stationId))")
    }

}
// MARK: - RentalStation
extension UnmanagedBikeRentalStation: RentalStation {
    /// UnmanagedBikeRentalStations are always nonfavourite stations.
    /// When a station is favourited it converted to ManagedBikeRentalStation
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
