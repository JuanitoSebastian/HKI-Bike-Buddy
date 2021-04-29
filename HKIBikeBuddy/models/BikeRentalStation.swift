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
    @Published var state: State
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
        self.state = try container.decode(State.self, forKey: .state)
        let favouriteDecode = try? container.decode(Bool.self, forKey: .favourite)
        self.favourite = favouriteDecode != nil ? favouriteDecode! : false
        let fetchedDecode = try? container.decode(Date.self, forKey: .fetched)
        self.fetched = fetchedDecode != nil ? fetchedDecode! : Date()
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
        self.state = state ? .inUse : .notInUse
        self.favourite = favourite
        self.fetched = Date()
    }

}

// MARK: - Computed properties:
extension BikeRentalStation {

    var location: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

    var isNearby: Bool {
        guard let userLocationUnwrapped = UserLocationService.shared.userLocation else { return false }
        return distance(to: userLocationUnwrapped) <= Double(UserDefaultsStore.shared.nearbyRadius)
    }

    var stationInUseString: String {
        return state == .inUse ? "Station in use" : "Station not in use"
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
    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
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

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case stationId = "stationId"
        case lat = "lat"
        case lon = "lon"
        case bikes = "bikesAvailable"
        case spaces = "spacesAvailable"
        case allowDropoff = "allowDropoff"
        case state = "state"
        case favourite = "favourite"
        case fetched = "fetched"
    }
}

// MARK: - Enums
extension BikeRentalStation {
    enum State: String, Codable {
        case inUse = "Station on"
        case notInUse = "Station off"
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
