//
//  AppState.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 2.4.2021.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation

class AppState: ObservableObject {

    static let shared = AppState()

    @Published private(set) var favouriteRentalStations: [BikeRentalStation]
    @Published private(set) var nearbyRentalStations: [BikeRentalStation]
    @Published private(set) var mainView: MainViewState
    @Published var notification: NotificationContent?
    @Published var detailedBikeRentalStation: BikeRentalStation?
    private var storeCancellable: AnyCancellable?
    private var userLocationServiceCancellable: AnyCancellable?

    private init() {
        self.favouriteRentalStations = []
        self.nearbyRentalStations = []
        self.mainView = .locationPrompt
    }
}

// MARK: - Subscriptions
extension AppState {

    func subscribeToBikeRentalStore() {
        if storeCancellable != nil { return }
        storeCancellable =
            BikeRentalStationStore.shared.bikeRentalStationIds.eraseToAnyPublisher().sink { fetched in

                self.setBikeRentalStations(
                    valuesToAdd: fetched
                                    .compactMap({ (stationId: String) in
                                        return self.getRentalStation(stationId: stationId)
                                    })
                                    .filter { $0.isNearby },
                    destination: &self.nearbyRentalStations,
                    animation: !self.nearbyRentalStations.isEmpty
                )

                self.setBikeRentalStations(
                    valuesToAdd: fetched
                                    .compactMap({ (stationId: String) in
                                        return self.getRentalStation(stationId: stationId)
                                    })
                        .filter { $0.favourite },
                    destination: &self.favouriteRentalStations,
                    animation: !self.favouriteRentalStations.isEmpty
                )
            }
    }

    func subscribeToUserLocationServiceState() {
        userLocationServiceCancellable =
            UserLocationService.shared.$locationAuthorization.eraseToAnyPublisher().sink { newValue in
                switch newValue {
                case .success:
                    self.mainView = .rentalStations

                case .denied:
                    self.mainView = .locationPrompt
                }
            }
    }

}

// MARK: - Computed variables
extension AppState {

    var userLocation: CLLocation? {
        UserLocationService.shared.userLocation
    }

    var userLocation2D: CLLocationCoordinate2D? {
        UserLocationService.shared.userLocation2D
    }

    var nearbyRadius: Int {
        UserDefaultsService.shared.nearbyDistance
    }

    var apiState: ApiOperationState {
        BikeRentalStationApiService.shared.apiOperationState
    }

    var locationServicesPromptDisplayed: Bool {
        UserDefaultsService.shared.locationServicesPromptDisplayed
    }

}

// MARK: - UI Functions
extension AppState {

    /// Fetches a Bike Rental Station from store
    /// - Parameter stationId: Id of the station to fetch
    /// - Returns: the Bike Rental Station object or nil if station is not found in the store
    func getRentalStation(stationId: String) -> BikeRentalStation? {
        BikeRentalStationStore.shared.bikeRentalStations[stationId]
    }

    /// Marks the favourite property true of a given Bike Rental Station
    /// - Parameter bikeRentalStation: Bike Rental Station object to mark as favourite
    func markStationAsFavourite(_ bikeRentalStation: BikeRentalStation) {
        bikeRentalStation.favourite = true
    }

    /// Marks the favourite property false of a given Bike Rental Station
    /// - Parameter bikeRentalStation: Bike Rental Station object to mark as non favourite
    func markStationAsNonFavourite(_ bikeRentalStation: BikeRentalStation) {
        bikeRentalStation.favourite = false
    }

    /// Adds given Bike Rental Station to list of favourite stations. Object is inserted in to the correct index.
    /// Stations are kept in order from closest to furthest
    /// - Parameter bikeRentalStation: Bike Rental Station object that should be added
    func addStationToFavouritesList(_ bikeRentalStation: BikeRentalStation) {
        favouriteRentalStations = insertStation(bikeRentalStation, toList: favouriteRentalStations)
    }

    func removeStationFromFavouritesList(_ bikeRentalStation: BikeRentalStation) {
        favouriteRentalStations = removeStation(bikeRentalStation.stationId, from: favouriteRentalStations)
    }

    func setNearbyRadius(radius: Int) {
        UserDefaultsService.shared.nearbyDistance = radius
    }

    func requestLocationAuthorization() {
        UserLocationService.shared.requestLocationServicesPermission()
    }

    func locationServicesRequested() {
        UserDefaultsService.shared.locationServicesPromptDisplayed = true
    }

    func fetchFromApi() {
        BikeRentalStationApiService.shared.updateStoreWithAPI()
    }

    func setDetailedViewStatation(_ bikeRentalStation: BikeRentalStation) {
        detailedBikeRentalStation = bikeRentalStation
    }

    func saveStore() {
        BikeRentalStationStore.shared.saveData()
    }

    func startUpdatingUserLocation() {
        UserLocationService.shared.startUpdatingUserLocation()
    }

    func stopUpdatingUserLocation() {
        UserLocationService.shared.stopUpdatingUserLocation()
    }

}
// MARK: - Non UI Functions
extension AppState {

    private func setBikeRentalStations(
        valuesToAdd: [BikeRentalStation],
        destination: inout [BikeRentalStation],
        animation: Bool
    ) {
        if animation {
            withAnimation {
                destination = valuesToAdd
            }
        } else {
            destination = valuesToAdd
        }
    }
}

// MARK: - Functions
extension AppState {

    private func removeStation(
        _ stationIdToRemove: String,
        from: [BikeRentalStation]
    ) -> [BikeRentalStation] {
        return from.filter { $0.stationId != stationIdToRemove}
    }

    private func insertStation(
        _ bikeRentalStationToInsert: BikeRentalStation,
        toList: [BikeRentalStation]
    ) -> [BikeRentalStation] {
        var bikeRentalStationsArray = toList
        var inserted = false

        if let insertDistance = bikeRentalStationToInsert.distance(to: userLocation) {
            for (index, bikeRentalStation) in bikeRentalStationsArray.enumerated() {
                guard let comparisonDistance = bikeRentalStation.distance(to: userLocation) else { continue }
                if insertDistance <= comparisonDistance {
                    bikeRentalStationsArray.insert(bikeRentalStationToInsert, at: index)
                    inserted = true
                    break
                }
            }
        }

        if !inserted {
            bikeRentalStationsArray.insert(bikeRentalStationToInsert, at: bikeRentalStationsArray.endIndex)
        }

        return bikeRentalStationsArray

    }
}

// MARK: - Enums

enum MainViewState {
    case rentalStations
    case locationPrompt
}
