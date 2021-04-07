//
//  HkiBikeBuddyTests.swift
//  HkiBikeBuddyTests
//
//  Created by Juan Covarrubias on 25.3.2021.
//
@testable import HelsinkiBikeBuddy
import XCTest
import MapKit

class BikeRentalStationStoreTests: XCTestCase {
    /*

    var stationIdToFetch = "074"
    let stationNames = ["Rajasaarentie", "Senaatintori", "Kesäkatu", "Brahen kenttä"]
    let stationIds = ["074", "014", "073", "045"]
    let stationLats = [60.183137, 60.1691278, 60.1792967, 60.1868618]
    let stationLons = [24.911127, 24.9526414, 24.9132504, 24.9509168]

    var rentalStationsForTesting: [RentalStation] {
        var rentalStations: [RentalStation] = []
        for index in 0...3 {
            let unmanagedBikeRentalStation = UnmanagedBikeRentalStation(
                stationId: stationIds[index],
                name: stationNames[index],
                allowDropoff: true,
                bikesAvailable: Int64(index),
                fetched: Date(),
                lat: stationLats[index],
                lon: stationLons[index],
                spacesAvailable: 5,
                state: true
            )
            rentalStations.append(unmanagedBikeRentalStation)
        }
        return rentalStations
    }

    /// Test the initial state of store. Both lists should be empty
    func testA_store_initialState_isEmpty() {
        XCTAssertTrue(BikeRentalStationStore.shared.nearbyBikeRentalStations.value.isEmpty)
        XCTAssertTrue(BikeRentalStationStore.shared.favouriteBikeRentalStations.value.isEmpty)
    }

    /// Test appending values to nearby stations
    func testB_store_addingFourNearbyStations() {
        BikeRentalStationStore.shared.nearbyBikeRentalStations.value = rentalStationsForTesting
        XCTAssertEqual(BikeRentalStationStore.shared.nearbyBikeRentalStations.value.count, 4)

        for (index, nearbyBikeRentalStation) in
            BikeRentalStationStore.shared.nearbyBikeRentalStations.value.enumerated() {
            XCTAssertEqual(nearbyBikeRentalStation.name, stationNames[index])
            XCTAssertEqual(nearbyBikeRentalStation.stationId, stationIds[index])
        }
    }

    /// Marking a nearby station as favourite and waiting for changes to be published
    func testC_store_markNearbyStationAsFavourite() {
        BikeRentalStationStore.shared.nearbyBikeRentalStations.value = rentalStationsForTesting
        guard let bikeRentalStation = BikeRentalStationStore.shared.nearbyBikeRentalStations.value.first else {
            XCTFail("Failed to fetch station from CoreData")
            return
        }
        BikeRentalStationStore.shared.favouriteStation(rentalStation: bikeRentalStation)
        let expectation = self.expectation(description: "Awaiting for favouriteBikeRentalStations publisher")

        let cancellable = BikeRentalStationStore.shared.favouriteBikeRentalStations.sink(
            receiveValue: { rentalStations in

                if rentalStations.count == 1 &&
                    rentalStations.first!.name == bikeRentalStation.name &&
                    rentalStations.first!.stationId == bikeRentalStation.stationId {
                    expectation.fulfill()
                }
            })

        waitForExpectations(timeout: 10)
        cancellable.cancel()
    }

    /// Fetching a favourite station
    func testD_store_fetchManagedStationFromCoreData_shouldReturnObject() {
        let fetchedStation = BikeRentalStationStore.shared.bikeRentalStationFromCoreData(
            stationId: stationIdToFetch
        )
        XCTAssertNotNil(fetchedStation)
    }

    /// Fetching a nonexistent favourite station
    func testE_store_fetchManagedStationFromCoreData_shouldReturnNil() {
        let fetchedStation = BikeRentalStationStore.shared.bikeRentalStationFromCoreData(stationId: "016")
        XCTAssertNil(fetchedStation)
    }

    /// Marking a favourite station as nonfavourite. Station is nearby so it should be added to list of nearby stations
    func testF_store_markStationNonfavourite_shouldBeAddedToNearby() {
        setUserLocation()
        guard let fetchedStation = BikeRentalStationStore.shared.bikeRentalStationFromCoreData(
            stationId: stationIdToFetch
        ) else {
            XCTFail("Failed to fetch station from CoreData")
            return
        }

        BikeRentalStationStore.shared.unfavouriteStation(rentalStation: fetchedStation)

        let expectationFavourite = self.expectation(description: "Station is added back to Nearby Stations")

        let cancellableFavourite = BikeRentalStationStore.shared.favouriteBikeRentalStations.sink(
            receiveValue: { rentalStations in
                if rentalStations.isEmpty && BikeRentalStationStore.shared.nearbyBikeRentalStations.value.count == 1 {
                    expectationFavourite.fulfill()
                }
            })

        waitForExpectations(timeout: 10)
        cancellableFavourite.cancel()
    }

    /// Marking a nonnearby station as favourite and waiting for changes to be published
    func testG_store_markNonnearbyStationAsFavourite() {
        BikeRentalStationStore.shared.nearbyBikeRentalStations.value = rentalStationsForTesting
        guard let bikeRentalStation = BikeRentalStationStore.shared.nearbyBikeRentalStations.value.first(
                where: { $0.stationId == "014" }
        ) else {
            XCTFail("Failed to fetch station from CoreData")
            return
        }
        BikeRentalStationStore.shared.favouriteStation(rentalStation: bikeRentalStation)
        let expectation = self.expectation(description: "Awaiting for favouriteBikeRentalStations publisher")

        let cancellable = BikeRentalStationStore.shared.favouriteBikeRentalStations.sink(
            receiveValue: { rentalStations in
                if rentalStations.count == 1 &&
                    rentalStations.first!.name == bikeRentalStation.name &&
                    rentalStations.first!.stationId == bikeRentalStation.stationId {
                    expectation.fulfill()
                }
            })

        waitForExpectations(timeout: 10)
        cancellable.cancel()
    }

    /// Unfavouriting a nonnearby station. Station should not be added to list of nearby stations anymore!
    func testH_store_markStationNonfavourite_shouldNotBeADdedToNearby() {
        setUserLocation()
        guard let fetchedStation = BikeRentalStationStore.shared.bikeRentalStationFromCoreData(
            stationId: "014"
        ) else {
            XCTFail("Failed to fetch station from CoreData")
            return
        }

        BikeRentalStationStore.shared.unfavouriteStation(rentalStation: fetchedStation)

        let expectationFavourite = self.expectation(description: "Station is added back to Nearby Stations")

        let cancellableFavourite = BikeRentalStationStore.shared.favouriteBikeRentalStations.sink(
            receiveValue: { rentalStations in
                if rentalStations.isEmpty {
                    if BikeRentalStationStore.shared.nearbyBikeRentalStations.value.isEmpty {
                        expectationFavourite.fulfill()
                    }
                }
            })

        waitForExpectations(timeout: 10)
        cancellableFavourite.cancel()
    }
 */
}

// MARK: - Helping functions
extension BikeRentalStationStoreTests {
    /*

    override func setUp() {
        BikeRentalStationStore.shared.nearbyBikeRentalStations.value = []
    }

    func setUserLocation() {
        // Location is set to Töölön Kirjasto
        UserLocationService.shared.testingLocation = CLLocation(
            latitude: 60.183356,
            longitude: 24.917324
        )
    }
 */
}
