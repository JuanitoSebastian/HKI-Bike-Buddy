//
//  BikeRentalStation.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.4.2021.
//

import Foundation
import CoreLocation

class BikeRentalStation: ObservableObject, Identifiable {

    let stationId: String
    var name: String
    @Published var lat: Double?
    @Published var lon: Double?
    @Published var bikes: Int?
    @Published var spaces: Int?
    @Published var allowDropoff: Bool?
    @Published var state: Bool?
    var favourite: Bool
    var fetched: Date?

    init(stationId: String, name: String) {
        self.stationId = stationId
        self.name = name
        self.favourite = true
    }

    init?(apiResultMapOptional: [String: Any?]?) {
        guard let apiResultMap = apiResultMapOptional else {
            Log.d("Found nil when unwrapping apiResultMap")
            return nil
        }
        // swiftlint:disable force_cast
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
        // swiftlint:enable force_cast
        self.stationId = fetchedStationId
        self.name = fetchedName
        self.allowDropoff = fetchedAllowDropoff
        self.bikes = fetchedBikesAvailable
        self.fetched = Date()
        self.lat = fetchedLat
        self.lon = fetchedLon
        self.spaces = fetchedSpacesAvailable
        self.state = Helper.parseStateString(fetchedState)
        self.favourite = false
    }
}

// MARK: - Computer properties:
extension BikeRentalStation {

    var location: CLLocation? {
        guard let latUnwrapped = lat,
              let lonUnwrapped = lon else { return nil }
        return CLLocation(latitude: latUnwrapped, longitude: lonUnwrapped)
    }

    var totalCapacity: Int? {
        guard let bikesUnwrapped = bikes,
              let spacesUnwrapped = spaces else { return nil }
        return bikesUnwrapped + spacesUnwrapped
    }
    var coordinate: CLLocationCoordinate2D? {
        guard let latUnwrapped = lat,
              let lonUnwrapped = lon else { return nil }
        return CLLocationCoordinate2D(latitude: latUnwrapped, longitude: lonUnwrapped)
    }

    var isNearby: Bool {
        guard let distanceUnwrapped = distance(to: UserLocationService.shared.userLocation) else { return false }
        return distanceUnwrapped <= Double(UserDefaultsService.shared.nearbyDistance)
    }

    var id: String {
        stationId
    }
}

// MARK: - Functions

extension BikeRentalStation {
    /// Calculate distance between RentalStation and parameter location
    /// - Parameter location: CLLocation object to which the distance is calculated to
    /// - Returns: A CLLocationDistance? object
    func distance(to location: CLLocation?) -> CLLocationDistance? {
        guard let locationUnwrapped = self.location,
            let toLocationUnwrapped = location else { return nil }
        return toLocationUnwrapped.distance(from: locationUnwrapped)
    }

    // swiftlint:disable force_cast
    /// Update RentalStation values with values provided
    /// - Parameter apiResultMapOptional: ResultMap provided from API
    func updateValues(apiResultMapOptional: [String: Any?]?) {
        guard let apiResultMap = apiResultMapOptional else {
            Log.d("Found nil when unwrapping apiResultMap")
            return
        }

        guard let fetchedName = apiResultMap["name"] as! String?,
              let fetchedBikesAvailable = apiResultMap["bikesAvailable"] as! Int?,
              let fetchedSpacesAvailable = apiResultMap["spacesAvailable"] as! Int?,
              let fetchedLat = apiResultMap["lat"] as! Double?,
              let fetchedLon = apiResultMap["lon"] as! Double?,
              let fetchedAllowDropoff = apiResultMap["allowDropoff"] as! Bool?,
              let fetchedState = apiResultMap["state"] as! String? else {
            Log.d("Found nil when unwrapping one of apiResultMap values")
            return
        }

        Log.i("Updating values for: \(name) (\(stationId)")
        self.name = fetchedName
        self.bikes = fetchedBikesAvailable
        self.spaces = fetchedSpacesAvailable
        self.lat = fetchedLat
        self.lon = fetchedLon
        self.allowDropoff = fetchedAllowDropoff
        self.state = Helper.parseStateString(fetchedState)
    }
    // swiftlint:enable force_cast
}

// MARK: - Equatable
extension BikeRentalStation: Equatable {
    static func ==(rhs: BikeRentalStation, lhs: BikeRentalStation) -> Bool {
        return rhs.id == lhs.id
    }
}

// MARK: - Hashable
extension BikeRentalStation: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
