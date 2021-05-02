//
//  BikeRentalStationAPITests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 2.5.2021.
//

@testable import HKIBikeBuddy
import XCTest

class BikeRentalStationAPITests: XCTestCase {

    let bikeRentalStationAPI =  BikeRentalStationAPI.shared
    let timeout: TimeInterval = 10

    func test_a_fetch_nearby_bike_rental_stations() {
        let lat = 60.173525
        let lon = 24.906431
        let nearbyRadius = 1000

        let expectation = self.expectation(description: "Awaiting API")

        bikeRentalStationAPI.fetchNearbyBikeRentalStations(
            lat: lat,
            lon: lon,
            radius: nearbyRadius
        ) { (_ fetchedBikeRentalStations: [BikeRentalStation]?, _ error: Error?) in
            guard error == nil else { return }
            guard let fetchedBikeRentalStations = fetchedBikeRentalStations else { return }

            if fetchedBikeRentalStations[0].stationId == "071" &&
                fetchedBikeRentalStations[1].stationId == "072" {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_b_fetch_multiple_bike_rental_stations() {
        let stationsIds = ["014", "114", "051"]

        let expectation = self.expectation(description: "Awaiting API")

        bikeRentalStationAPI.fetchBikeRentalStations(stationIds: stationsIds) {
            (_ fetchedBikeRentalStations: [BikeRentalStation]?, _ error: Error?) in
            guard error == nil else { return }
            guard let fetchedBikeRentalStations = fetchedBikeRentalStations else { return }
            if fetchedBikeRentalStations.count == stationsIds.count {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_c_fetch_single_bike_rental_station() {
        let stationId = "014"

        let expectation = self.expectation(description: "Awaiting API")

        bikeRentalStationAPI.fetchBikeRentalStation(stationId: stationId) {
            (_ bikeRentalStation: BikeRentalStation?, _ error: Error?) in
            guard error == nil else { return }
            guard let bikeRentalStation = bikeRentalStation else { return }
            guard bikeRentalStation.stationId == stationId else { return }
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)
    }

    func test_d_fetch_single_bike_rental_station_error() {
        let stationId = "01sa4"

        let expectation = self.expectation(description: "Awaiting API")

        bikeRentalStationAPI.fetchBikeRentalStation(stationId: stationId) {
            (_ bikeRentalStation: BikeRentalStation?, _ error: Error?) in
            guard error == nil else {
                expectation.fulfill()
                return
            }
        }

        waitForExpectations(timeout: timeout)
    }
}
