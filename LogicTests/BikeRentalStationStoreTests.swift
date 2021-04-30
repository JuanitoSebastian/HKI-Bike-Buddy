//
//  BikeRentalStationStoreTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 26.4.2021.
//
@testable import HKIBikeBuddy
import XCTest

class BikeRentalStationStoreTests: XCTestCase {

    let store = BikeRentalStationStore.shared
    let timeout: TimeInterval = 10
    var stationIds: [String] = []

    func test_a_initial_state_of_store() {
        XCTAssertTrue(store.bikeRentalStations.isEmpty)
        XCTAssertTrue(store.bikeRentalStationIds.value.isEmpty)
    }

    func test_b_stations_inserted_are_published() {
        let expectation = self.expectation(description: "Awaiting publisher")

        store.insertStations(BikeRentalStation.placeholderStations)

        _ = store.bikeRentalStationIds.sink { receivedValue in
            if receivedValue.count == BikeRentalStation.placeholderStations.count {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_c_station_inserted_published() {
        let expectation = self.expectation(description: "Awaiting publisher")

        let station = BikeRentalStation(
            stationId: "094",
            name: "Laajalahden aukio",
            lat: 60.19793090756802,
            lon: 24.876221716500662,
            bikes: 13,
            spaces: 13,
            allowDropoff: true,
            state: true,
            favourite: true
        )

        store.insertStations([station])

        _ = store.bikeRentalStationIds.sink { receivedValue in
            if receivedValue.contains("094") {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_d_existing_station_values_updated() {
        let station = BikeRentalStation(
            stationId: "094",
            name: "Vaahtera-aukio",
            lat: 10,
            lon: -10,
            bikes: 1,
            spaces: 23,
            allowDropoff: false,
            state: true,
            favourite: true
        )

        store.insertStations([station])

        let stationFromStore = store.bikeRentalStations[station.stationId]

        XCTAssertNotNil(stationFromStore)

        XCTAssertEqual(station, stationFromStore!)
        XCTAssertEqual(station.name, stationFromStore!.name)
        XCTAssertEqual(station.lat, stationFromStore!.lat)
        XCTAssertEqual(station.lon, stationFromStore!.lon)
        XCTAssertEqual(station.bikes, stationFromStore!.bikes)
        XCTAssertEqual(station.spaces, stationFromStore!.spaces)
        XCTAssertEqual(station.allowDropoff, stationFromStore!.allowDropoff)
        XCTAssertEqual(station.state, stationFromStore!.state)
        XCTAssertEqual(station.favourite, stationFromStore!.favourite)
    }

    func test_e_save_store() {
        stationIds = store.bikeRentalStationIds.value
        XCTAssertNoThrow(try store.saveData())
        store.clearStore()
    }

    func test_f_load_store() {
        XCTAssertNoThrow(try store.loadData())
        let loadedStationsIds = Set<String>(BikeRentalStationStore.shared.bikeRentalStationIds.value)

        for stationId in stationIds {
            XCTAssertTrue(loadedStationsIds.contains(stationId))
        }
        store.clearStore()
    }
}
