//
//  BikeRentalStation.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.4.2021.
//

import Foundation
import CoreLocation

/// A station where city bikes can be rented from and returned to 🚲
class BikeRentalStation: ObservableObject {

    let stationId: String
    var name: String
    @Published var lat: Double
    @Published var lon: Double
    @Published var bikes: Int
    @Published var spaces: Int
    @Published var allowDropoff: Bool
    @Published var state: Bool
    @Published var favourite: Bool
    var fetched: Date

    /// Decoder init for when stations are decoded from persistent store
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stationId = try container.decode(String.self, forKey: .stationId)
        self.name = try container.decode(String.self, forKey: .name)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.lon = try container.decode(Double.self, forKey: .lon)
        self.bikes = try container.decode(Int.self, forKey: .bikes)
        self.spaces = try container.decode(Int.self, forKey: .spaces)
        self.allowDropoff = try container.decode(Bool.self, forKey: .allowDropoff)
        self.state = try container.decode(Bool.self, forKey: .state)
        self.favourite = try container.decode(Bool.self, forKey: .favourite)
        self.fetched = try container.decode(Date.self, forKey: .fetched)
    }

    /// ApiResultMapOptional init for when stations are created from API response
    /// - Parameter apiResultMapOptional: Dictionary object obtained from API
    /// - Returns: If the resultMap from API contains missing values nil is returned
    init?(apiResultMapOptional: [String: Any?]?) {
        guard let apiResultMap = apiResultMapOptional else {
            Log.d("Found nil when unwrapping apiResultMap")
            return nil
        }

        guard let fetchedStationId = apiResultMap["stationId"] as? String,
              let fetchedName = apiResultMap["name"] as? String,
              let fetchedBikesAvailable = apiResultMap["bikesAvailable"] as? Int,
              let fetchedSpacesAvailable = apiResultMap["spacesAvailable"] as? Int,
              let fetchedLat = apiResultMap["lat"] as? Double,
              let fetchedLon = apiResultMap["lon"] as? Double,
              let fetchedAllowDropoff = apiResultMap["allowDropoff"] as? Bool,
              let fetchedState = apiResultMap["state"] as? String else {
            Log.d("Found nil when unwrapping one of apiResultMap values")
            return nil
        }

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

    /// Internal init used for testing and manual creation of BikeRentalStations
    internal init(
        stationId: String,
        name: String,
        lat: Double,
        lon: Double,
        bikes: Int,
        spaces: Int,
        allowDropoff: Bool,
        state: Bool,
        favourite: Bool
    ) {
        self.stationId = stationId
        self.name = name
        self.lat = lat
        self.lon = lon
        self.bikes = bikes
        self.spaces = spaces
        self.allowDropoff = allowDropoff
        self.state = state
        self.favourite = favourite
        self.fetched = Date()
    }

}

// MARK: - Computed properties:
extension BikeRentalStation {

    var location: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var isNearby: Bool {
        guard let distanceUnwrapped = distance(to: UserLocationService.shared.userLocation) else { return false }
        return distanceUnwrapped <= Double(UserDefaultsService.shared.nearbyDistance)
    }

    var stationInUseString: String {
        return state ? "Station in use" : "Station not in use"
    }

    var allowDropoffString: String {
        return allowDropoff ? "Accepts dropoffs" : "No dropoffs"
    }

    var lastUpdatedString: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")

        if calendar.isDateInToday(fetched) {
            let dateString = formatter.string(from: fetched)
            return "Updated \(dateString)"
        }

        if calendar.isDateInYesterday(fetched) {
            let dateString = formatter.string(from: fetched)
            return "Updated yesterday \(dateString)"
        }
        return "Updated a long time ago"
    }
}

// MARK: - Functions
extension BikeRentalStation {

    /// Calculate distance between self and parameter location
    /// - Parameter location: CLLocation? object to which the distance is calculated to
    /// - Returns: A CLLocationDistance? object
    func distance(to location: CLLocation?) -> CLLocationDistance? {
        guard let toLocationUnwrapped = location else { return nil }
        return toLocationUnwrapped.distance(from: self.location)
    }

    /// Update selfs values with values provided
    /// - Parameter apiResultMapOptional: ResultMap provided from API
    func updateValues(apiResultMapOptional: [String: Any?]?) {
        guard let apiResultMap = apiResultMapOptional else {
            Log.d("Found nil when unwrapping apiResultMap")
            return
        }

        guard let fetchedName = apiResultMap["name"] as? String,
              let fetchedBikesAvailable = apiResultMap["bikesAvailable"] as? Int,
              let fetchedSpacesAvailable = apiResultMap["spacesAvailable"] as? Int,
              let fetchedLat = apiResultMap["lat"] as? Double,
              let fetchedLon = apiResultMap["lon"] as? Double,
              let fetchedAllowDropoff = apiResultMap["allowDropoff"] as? Bool,
              let fetchedState = apiResultMap["state"] as? String else {
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
        self.fetched = Date()
    }
}

// MARK: - Codable
extension BikeRentalStation: Codable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stationId, forKey: .stationId)
        try container.encode(name, forKey: .name)
        try container.encode(lat, forKey: .lat)
        try container.encode(lon, forKey: .lon)
        try container.encode(bikes, forKey: .bikes)
        try container.encode(spaces, forKey: .spaces)
        try container.encode(allowDropoff, forKey: .allowDropoff)
        try container.encode(state, forKey: .state)
        try container.encode(favourite, forKey: .favourite)
        try container.encode(fetched, forKey: .fetched)
    }

    enum CodingKeys: CodingKey {
        case name
        case stationId
        case lat
        case lon
        case bikes
        case spaces
        case allowDropoff
        case state
        case favourite
        case fetched
    }
}

// MARK: - Identifiable
extension BikeRentalStation: Identifiable {
    var id: String {
        stationId
    }
}

// MARK: - Equatable
extension BikeRentalStation: Equatable {
    static func == (lhs: BikeRentalStation, rhs: BikeRentalStation) -> Bool {
        return rhs.id == lhs.id
    }
}

// MARK: - Comparable
extension BikeRentalStation: Comparable {
    static func < (lhs: BikeRentalStation, rhs: BikeRentalStation) -> Bool {
        guard let userLocation = UserLocationService.shared.userLocation else { return false }
        guard let lhsDistance = lhs.distance(to: userLocation) else { return false }
        guard let rhsDistance = rhs.distance(to: userLocation) else { return true }
        return lhsDistance < rhsDistance
    }

    static func <= (lhs: BikeRentalStation, rhs: BikeRentalStation) -> Bool {
        guard let userLocation = UserLocationService.shared.userLocation else { return false }
        guard let lhsDistance = lhs.distance(to: userLocation) else { return false }
        guard let rhsDistance = rhs.distance(to: userLocation) else { return true }
        return lhsDistance <= rhsDistance
    }

    static func > (lhs: BikeRentalStation, rhs: BikeRentalStation) -> Bool {
        guard let userLocation = UserLocationService.shared.userLocation else { return false }
        guard let lhsDistance = lhs.distance(to: userLocation) else { return false }
        guard let rhsDistance = rhs.distance(to: userLocation) else { return true }
        return lhsDistance > rhsDistance
    }

    static func >= (lhs: BikeRentalStation, rhs: BikeRentalStation) -> Bool {
        guard let userLocation = UserLocationService.shared.userLocation else { return false }
        guard let lhsDistance = lhs.distance(to: userLocation) else { return false }
        guard let rhsDistance = rhs.distance(to: userLocation) else { return true }
        return lhsDistance >= rhsDistance
    }
}

// MARK: - Hashable
extension BikeRentalStation: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Placeholder Data
extension BikeRentalStation {

    /// These stations are used in widget and Xcode previews
    static var placeholderStations: [BikeRentalStation] = [
        BikeRentalStation(
            stationId: "014",
            name: "Senaatintori",
            lat: 60.1691278,
            lon: 24.9526414,
            bikes: 10,
            spaces: 13,
            allowDropoff: true,
            state: true,
            favourite: false
        ),

        BikeRentalStation(
            stationId: "008",
            name: "Vanha kirkkopuisto",
            lat: 60.1652883,
            lon: 24.9391499,
            bikes: 15,
            spaces: 9,
            allowDropoff: true,
            state: true,
            favourite: false
        ),

        BikeRentalStation(
            stationId: "001",
            name: "Kaivopuisto",
            lat: 60.15544479382098,
            lon: 24.950292889690314,
            bikes: 11,
            spaces: 13,
            allowDropoff: true,
            state: true,
            favourite: false
        )
    ]
}
