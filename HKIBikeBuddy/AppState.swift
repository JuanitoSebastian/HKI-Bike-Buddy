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

    @Published private(set) var mainView: MainViewState

    @Published private(set) var favouriteRentalStations: [BikeRentalStation]
    @Published private(set) var nearbyRentalStations: [BikeRentalStation]

    @Published var notification: NotificationContent?
    @Published var detailedBikeRentalStation: BikeRentalStation?
    var apiState: ApiState

    private var storeCancellable: AnyCancellable?
    private var userLocationAuthorizationCancellable: AnyCancellable?
    private var userLocationCancellable: AnyCancellable?

    private init() {
        self.apiState = .idle
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
                if UserLocationService.shared.userLocation == nil { return }
                self.sortAndSetBikeRentalStations(stationIds: fetched)
            }
    }

    func subscribeToUserLocation() {
        if userLocationCancellable != nil { return }
        userLocationCancellable = UserLocationService.shared.$userLocation.eraseToAnyPublisher().sink { _ in
            if UserLocationService.shared.userLocation == nil { return }
            self.sortAndSetBikeRentalStations(stationIds: BikeRentalStationStore.shared.bikeRentalStationIds.value)
        }
    }

    private func sortAndSetBikeRentalStations(stationIds: [String]) {
        let bikeRentalStationFromIds = stationIds
            .compactMap { self.getRentalStation(stationId: $0) }
            .sorted()

        setBikeRentalStations(
            valuesToAdd: bikeRentalStationFromIds
                .filter { $0.isNearby },
            destination: &self.nearbyRentalStations,
            animation: !self.nearbyRentalStations.isEmpty
        )

        setBikeRentalStations(
            valuesToAdd: bikeRentalStationFromIds
                .filter { $0.favourite },
            destination: &self.favouriteRentalStations,
            animation: !self.favouriteRentalStations.isEmpty
        )
    }

    func subscribeToUserLocationServiceAuthorization() {
        userLocationAuthorizationCancellable =
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
        UserDefaultsStore.shared.nearbyRadius
    }

    var locationServicesPromptDisplayed: Bool {
        UserDefaultsStore.shared.locationServicesPromptDisplayed
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

    /// Removes given Bike Rental Station from list of favourites
    /// - Parameter bikeRentalStation: Bike Rental Station object to remove
    func removeStationFromFavouritesList(_ bikeRentalStation: BikeRentalStation) {
        favouriteRentalStations = removeStation(bikeRentalStation.stationId, from: favouriteRentalStations)
    }

    /// Sets and stores the maximum distance for stations to be considered nearby.
    /// - Parameter radius: The new value in meters
    func setNearbyRadius(radius: Int) {
        UserDefaultsStore.shared.nearbyRadius = radius
    }

    /// Request location authorization from user. Calling this method triggers the location services alert from system.
    /// *This alert can only be shown once!* That is why this method also sets the UserDefaultsStore
    /// locationServicesPromptDisplayed property to true so that the app is aware that the alert has already been shown.
    func requestLocationAuthorization() {
        UserLocationService.shared.requestLocationServicesPermission()
        UserDefaultsStore.shared.locationServicesPromptDisplayed = true
    }

    /// Performs a fetch from API. Nearby stations are fetched and favourite stations are updated.
    func fetchFromApi() {
        guard let userLocationUnwrapped = userLocation else { return }
        var stationsUpdatePending: Set<String> = []
        let dispatchGroup = DispatchGroup()
        Log.i("Setting api state to loading")
        apiState = .loading

        dispatchGroup.notify(queue: DispatchQueue.main) {
            Log.i("Setting api state to idle")
            self.apiState = .idle
        }

        RoutingAPI.shared.fetchNearbyBikeRentalStations(
            lat: userLocationUnwrapped.coordinate.latitude,
            lon: userLocationUnwrapped.coordinate.longitude,
            nearbyRadius: nearbyRadius
        ) { (_ bikeRentalStations: [BikeRentalStation]?, _ error: Error?) in
            guard let bikeRentalStationsFromApi = bikeRentalStations else {
                return
            }
            dispatchGroup.enter()
            // Update values in main thread
            DispatchQueue.main.async {
                stationsUpdatePending = BikeRentalStationStore.shared.insertStations(bikeRentalStationsFromApi)
                Log.i("Setting stations and leaving")
                dispatchGroup.leave()
            }
        }

        for stationId in Array(stationsUpdatePending) {
            dispatchGroup.enter()
            RoutingAPI.shared.fetchBikeRentalStation(
                stationId: stationId
            ) { (_ bikeRentalStation: BikeRentalStation?, _ error: Error?) in
                guard let bikeRentalStation = bikeRentalStation else {
                    return
                }
                // Update values in main thread
                DispatchQueue.main.async {
                    BikeRentalStationStore.shared.insertStation(bikeRentalStation)
                    Log.i("Setting station and leaving")
                    dispatchGroup.leave()
                }
            }
        }
    }

    /// Saves the Bike Rental Station Store
    func saveBikeRentalStationStore() {
        BikeRentalStationStore.shared.saveData()
    }

    /// Starts precise monitoring of user location
    func startMonitoringUserLocation() {
        UserLocationService.shared.startUpdatingUserLocation()
    }

    /// Stop precise monitoring of user location
    func stopMonitoringUserLocation() {
        UserLocationService.shared.stopUpdatingUserLocation()
    }

}

// MARK: - Functions
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

    /// Removes Bike Rental Station from list
    /// - Parameter stationIdToRemove: The stationId of the Bike Rental Station that should be removed
    /// - Parameter from: [BikeRentalStation] from which to remove the station from
    /// - Returns: [BikeRentalStation] with the station removed
    private func removeStation(
        _ stationIdToRemove: String,
        from: [BikeRentalStation]
    ) -> [BikeRentalStation] {
        return from.filter { $0.stationId != stationIdToRemove}
    }

    /// Inserts given Bike Rental Station to list while keeping stations in order from nearest to furthest from user.
    /// If location data is unavailable the station is inserted to the end of the list.
    /// - Parameter bikeRentalStationToInsert: BikeRentalStation object to insert.
    /// - Parameter toList: List to insert station to.
    /// - Returns: The given list with the given station inserted.
    private func insertStation(
        _ bikeRentalStationToInsert: BikeRentalStation,
        toList: [BikeRentalStation]
    ) -> [BikeRentalStation] {

        var bikeRentalStationsArray = toList

        // Flag for checking that insertion was succesfull
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
extension AppState {
    enum MainViewState {
        case rentalStations
        case locationPrompt
    }

    enum ApiState {
        case idle
        case loading
    }
}
