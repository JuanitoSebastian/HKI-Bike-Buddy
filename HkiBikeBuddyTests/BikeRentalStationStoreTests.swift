//
//  HkiBikeBuddyTests.swift
//  HkiBikeBuddyTests
//
//  Created by Juan Covarrubias on 25.3.2021.
//
@testable import HelsinkiBikeBuddy
import XCTest

class BikeRentalStationStoreTests: XCTestCase {

    var bikeRentalStationStore = BikeRentalStationStore.testing
    var bikeRentalStation: RentalStation = UnmanagedBikeRentalStation(
        stationId: "015",
        name: "Kinaporinkatu",
        allowDropoff: true,
        bikesAvailable: 6,
        fetched: Date(),
        lat: -1,
        lon: -1,
        spacesAvailable: 14,
        state: true
    )

    func testA_store_initialState_isEmpty() {
        XCTAssertTrue(bikeRentalStationStore.nearbyBikeRentalStations.value.isEmpty)
        XCTAssertTrue(bikeRentalStationStore.favouriteBikeRentalStations.value.isEmpty)
    }

    func testB_store_addingNearbyStations() {
        let stationNames = ["Rajasaarentie", "Senaatintori", "Kesäkatu", "Braahen kenttä"]

        for (index, name) in stationNames.enumerated() {
            let unmanagedBikeRentalStation = UnmanagedBikeRentalStation(
                stationId: String(index),
                name: name,
                allowDropoff: index % 2 == 0,
                bikesAvailable: Int64(index),
                fetched: Date(),
                lat: -1,
                lon: -1,
                spacesAvailable: 5,
                state: true
            )

            bikeRentalStationStore.nearbyBikeRentalStations.value.append(unmanagedBikeRentalStation)
        }
        bikeRentalStationStore.nearbyBikeRentalStations.value.append(bikeRentalStation)

        XCTAssertEqual(bikeRentalStationStore.nearbyBikeRentalStations.value.count, 5)
    }

    func testC_store_markStationAsFavourite() {
        bikeRentalStationStore.favouriteStation(rentalStation: bikeRentalStation)
        let expectation = self.expectation(description: "Awaiting for favouriteBikeRentalStations publisher")

        let cancellable = bikeRentalStationStore.favouriteBikeRentalStations.sink(receiveValue: { rentalStations in

            if rentalStations.count == 1 {
                expectation.fulfill()
            }
        })

        waitForExpectations(timeout: 10)
        cancellable.cancel()
    }

    func testD_store_fetchManagedStationFromCoreData_shouldReturnObject() {
        let fetchedStation = bikeRentalStationStore.bikeRentalStationFromCoreData(
            stationId: bikeRentalStation.stationId
        )
        XCTAssertNotNil(fetchedStation)
        XCTAssertEqual(fetchedStation!.name, bikeRentalStation.name)
    }

    func testE_store_fetchManagedStationFromCoreData_shouldReturnNil() {
        let fetchedStation = bikeRentalStationStore.bikeRentalStationFromCoreData(stationId: "016")
        XCTAssertNil(fetchedStation)
    }

    func testF_store_markStationNonfavourite() {
        let fetchedStation = bikeRentalStationStore.bikeRentalStationFromCoreData(
            stationId: bikeRentalStation.stationId
        )
        bikeRentalStationStore.unfavouriteStation(rentalStation: fetchedStation!)

        XCTAssertTrue(bikeRentalStationStore.favouriteBikeRentalStations.value.isEmpty)

    }

}
