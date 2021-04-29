//
//  AppStateTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 26.4.2021.
//

@testable import HKIBikeBuddy
import Combine
import XCTest
import CoreLocation

class AppStateTests: XCTestCase {

    let appState = AppState.shared
    var userLocationAuthorization = CurrentValueSubject<UserLocationService.LocationAuthorizationStatus, Never>(.denied)

    let timeout: TimeInterval = 10

    func test_a_check_appstate_initial_state() {
        BikeRentalStationStore.shared.clearStore()
        XCTAssertEqual(appState.apiState, .loading)
        XCTAssertTrue(appState.favouriteRentalStations.isEmpty)
        XCTAssertTrue(appState.nearbyRentalStations.isEmpty)
        XCTAssertEqual(appState.mainView, .locationPrompt)
    }

    func test_b_check_mainViewState_publisher() {
        appState.subscribeToUserLocationServiceAuthorization(publisher: userLocationAuthorization.eraseToAnyPublisher())

        let expectation = self.expectation(description: "Awaiting publisher")

        userLocationAuthorization.value = .success

        _ = appState.$mainView.eraseToAnyPublisher().sink { newValue in
            if newValue == .rentalStations {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_c_user_location_matches_location_services() {
        XCTAssertEqual(appState.userLocation, UserLocationService.shared.userLocation)
        UserLocationService.shared.setUserLocation(location: CLLocation(latitude: 60.157038, longitude: 24.943239))
        XCTAssertEqual(appState.userLocation, UserLocationService.shared.userLocation)
    }

    func test_d_nearby_radius_matches_userdefaultsstore() {
        XCTAssertEqual(appState.nearbyRadius, UserDefaultsStore.shared.nearbyRadius)
        UserDefaultsStore.shared.nearbyRadius = 2000
        XCTAssertEqual(appState.nearbyRadius, 2000)
        UserDefaultsStore.shared.nearbyRadius = 1000
    }

    func test_e_locationservicespromptdisplayed_matches_userdefaultsstore() {
        XCTAssertEqual(
            appState.locationServicesPromptDisplayed,
            UserDefaultsStore.shared.locationServicesPromptDisplayed
        )
        UserDefaultsStore.shared.locationServicesPromptDisplayed = true
        XCTAssertEqual(appState.locationServicesPromptDisplayed, true)
        UserDefaultsStore.shared.locationServicesPromptDisplayed = false
    }

    func test_f_adding_stations_to_store_app_state_publisher_favourite() {
        BikeRentalStationStore.shared.clearStore()
        appState.subscribeToBikeRentalStore()
        UserLocationService.shared.setUserLocation(
            location:
                CLLocation(
                    latitude: 60.168756,
                    longitude: 24.941775
                )
        ) // Stockan kello
        let expectation = self.expectation(description: "Awaiting publisher")

        let stationToAdd = BikeRentalStation(
            stationId: "999",
            name: "Mäkelänkatu",
            lat: 60.198172,
            lon: 24.947807,
            bikes: 11,
            spaces: 13,
            allowDropoff: true,
            state: true,
            favourite: true
        )

        BikeRentalStationStore.shared.insertStations([stationToAdd])

        _ = appState.$favouriteRentalStations.eraseToAnyPublisher().sink { receivedValue in
            if receivedValue.count == 1 {
                let station = receivedValue.first!
                if station.name == stationToAdd.name {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_g_adding_stations_to_store_app_state_publisher_favourite_insertion() {

        appState.markStationAsFavourite(BikeRentalStation.placeholderStations[1])
        appState.addStationToFavouritesList(BikeRentalStation.placeholderStations[1])

        XCTAssertEqual(BikeRentalStation.placeholderStations[1], appState.favouriteRentalStations.first!)
    }

    /// Checks that stations are in the right order
    func test_h_adding_stations_to_store_app_state_publisher_nearby() {
        BikeRentalStationStore.shared.clearStore()
        let expectation = self.expectation(description: "Awaiting publisher")

        UserLocationService.shared.setUserLocation(location: CLLocation(latitude: 60.168756, longitude: 24.941775)) // Stockan kelllo

        BikeRentalStationStore.shared.insertStations(BikeRentalStation.placeholderStations)

        _ = appState.$nearbyRentalStations.eraseToAnyPublisher().sink { newValue in
            if newValue.count == 2 &&
                newValue.first!.name == "Vanha kirkkopuisto" {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_j_favouriting_and_unfavouriting_a_station() {
        BikeRentalStationStore.shared.clearStore()
        let stationToFavourite = BikeRentalStation(
            stationId: "999",
            name: "Mäkelänkatu",
            lat: 60.198172,
            lon: 24.947807,
            bikes: 11,
            spaces: 13,
            allowDropoff: true,
            state: true,
            favourite: false
        )

        // Favourite
        appState.markStationAsFavourite(stationToFavourite)
        appState.addStationToFavouritesList(stationToFavourite)

        XCTAssertTrue(stationToFavourite.favourite)
        XCTAssertTrue(appState.favouriteRentalStations.contains(stationToFavourite))

        // Unfavourite
        appState.markStationAsNonFavourite(stationToFavourite)
        appState.removeStationFromFavouritesList(stationToFavourite)

        XCTAssertFalse(stationToFavourite.favourite)
        XCTAssertFalse(appState.favouriteRentalStations.contains(stationToFavourite))
    }

    func test_k_set_nearby_radius_from_appstate() {
        appState.setNearbyRadius(radius: 600)
        XCTAssertEqual(appState.nearbyRadius, 600)
        appState.setNearbyRadius(radius: 1000)
    }

}
