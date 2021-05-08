//
//  HkiBikeBuddyLogicTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 25.4.2021.
//
@testable import HKIBikeBuddy
import XCTest
import CoreLocation

class BikeRentalStationTests: XCTestCase {

    /// Tests Location object and distance
    func test_a_bike_rental_station_location_properties() {

        let firstBikeRentalStation = BikeRentalStation.placeholderStations[0]
        let seconBikeRentalStation = BikeRentalStation.placeholderStations[1]

        XCTAssertEqual(firstBikeRentalStation.lat, firstBikeRentalStation.location.coordinate.latitude)
        XCTAssertEqual(firstBikeRentalStation.lon, firstBikeRentalStation.location.coordinate.longitude)

        XCTAssertTrue(firstBikeRentalStation.distance(to: seconBikeRentalStation.location) < 863)
        XCTAssertTrue(firstBikeRentalStation.distance(to: seconBikeRentalStation.location) > 861)
    }

    func test_c_bike_rental_station_computed_string_station_not_in_use() {
        let bikeRentalStation = BikeRentalStation.placeholderStations[
            Int.random(in: 0..<BikeRentalStation.placeholderStations.count)
        ]

        bikeRentalStation.state = .notInUse
        bikeRentalStation.allowDropoff = false

    }

    func test_d_bike_rental_station_encoding_and_decoding() {
        let index = Int.random(in: 0..<BikeRentalStation.placeholderStations.count)
        let chosenStation = BikeRentalStation.placeholderStations[index]
        let data = try? encodeStationToData(bikeRentalStation: chosenStation)
        XCTAssertNotNil(data)

        let decodedStation = try? decodeStationFromData(data: data!)
        XCTAssertNotNil(decodedStation)

        XCTAssertEqual(chosenStation, decodedStation!)
        XCTAssertEqual(chosenStation.name, decodedStation!.name)
        XCTAssertEqual(chosenStation.lat, decodedStation!.lat)
        XCTAssertEqual(chosenStation.lon, decodedStation!.lon)
        XCTAssertEqual(chosenStation.bikes, decodedStation!.bikes)
        XCTAssertEqual(chosenStation.spaces, decodedStation!.spaces)
        XCTAssertEqual(chosenStation.allowDropoff, decodedStation!.allowDropoff)
        XCTAssertEqual(chosenStation.state, decodedStation!.state)
        XCTAssertEqual(chosenStation.favourite, decodedStation!.favourite)
    }
}
// MARK: - Helper functions
extension BikeRentalStationTests {

    func encodeStationToData(bikeRentalStation: BikeRentalStation) throws -> Data {
        return try JSONEncoder().encode(bikeRentalStation)
    }

    func decodeStationFromData(data: Data) throws -> BikeRentalStation {
        return try JSONDecoder().decode(BikeRentalStation.self, from: data)
    }
}
