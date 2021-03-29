//
//  RentalStation.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.2.2021.
//

import Foundation
import CoreLocation

protocol RentalStation: AnyObject {

    var stationId: String { get set }
    var name: String { get set }
    var lat: Double { get set }
    var lon: Double { get set }
    var state: Bool { get set }
    var allowDropoff: Bool { get set }
    var spacesAvailable: Int64 { get set }
    var bikesAvailable: Int64 { get set }
    var fetched: Date { get set }

    var favourite: Bool { get }
    var location: CLLocation { get }
    var totalCapacity: Int { get }
    var id: String { get }
    var coordinate: CLLocationCoordinate2D { get }

    func distance(to location: CLLocation) -> CLLocationDistance

}

// MARK: - Default implementations of computed variables and functions
extension RentalStation {

    var location: CLLocation {
        return CLLocation(latitude: lat, longitude: lon)
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var totalCapacity: Int {
        Int(spacesAvailable + bikesAvailable)
    }

    public var id: String {
        stationId
    }

    /// Calculate distance between RentalStation and parameter location
    /// - Parameter location: CLLocation object to which the distance is calculated to
    /// - Returns: A CLLocationDistance object
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
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
        self.bikesAvailable = Int64(fetchedBikesAvailable)
        self.spacesAvailable = Int64(fetchedSpacesAvailable)
        self.lat = fetchedLat
        self.lon = fetchedLon
        self.allowDropoff = fetchedAllowDropoff
        self.state = Helper.parseStateString(fetchedState)
    }
    // swiftlint:enable force_cast
}
