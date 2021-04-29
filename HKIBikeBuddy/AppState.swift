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

    @Published var alert: AlertContent?
    @Published var detailedBikeRentalStation: BikeRentalStation?

    @Published var reachability: Bool?
    var apiState: ApiState

    private var storeCancellable: AnyCancellable?
    private var userLocationAuthorizationCancellable: AnyCancellable?
    private var userLocationCancellable: AnyCancellable?
    private var apiReachability: AnyCancellable?

    private init() {
        self.apiState = .loading
        self.favouriteRentalStations = []
        self.nearbyRentalStations = []
        self.mainView = .locationPrompt
        #if DEBUG
        guard !Helper.isRunningTests() else { return }
        #endif
        try? addReachabilityObserver()
    }

    deinit {
        removeReachabilityObserver()
    }
}

// MARK: - Subscriptions
extension AppState {

    func subscribeToBikeRentalStore(
        publisher: AnyPublisher<[String], Never> =
            BikeRentalStationStore.shared.bikeRentalStationIds.eraseToAnyPublisher()
    ) {
        guard storeCancellable == nil else { return }
        storeCancellable =
            publisher.sink { fetched in
                if UserLocationService.shared.userLocation == nil { return }
                self.fetchStationsFromStoreAndSort(stationIds: fetched)
            }
    }

    func subscribeToUserLocation(
        publisher: AnyPublisher<CLLocation?, Never> =
            UserLocationService.shared.$userLocation.eraseToAnyPublisher()
    ) {
        guard userLocationCancellable == nil else { return }
        userLocationCancellable = publisher.sink { receivedValue in
            guard receivedValue != nil else { return }
            self.fetchStationsFromStoreAndSort(stationIds: BikeRentalStationStore.shared.bikeRentalStationIds.value)
        }
    }

    func subscribeToUserLocationServiceAuthorization(
        publisher: AnyPublisher<UserLocationService.LocationAuthorizationStatus, Never> =
            UserLocationService.shared.$locationAuthorization.eraseToAnyPublisher()
    ) {
        guard userLocationAuthorizationCancellable == nil else { return }
        userLocationAuthorizationCancellable =
            publisher.sink { newValue in
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
        self.alert = AlertContent(title: "Notification", message: "Setting nearby radius", type: .notice)
        UserDefaultsStore.shared.nearbyRadius = radius
    }

    /// Request location authorization from user. Calling this method triggers the location services alert from system.
    /// *This alert can only be shown once!* That is why this method also sets the UserDefaultsStore
    /// locationServicesPromptDisplayed property to true so that the app is aware that the alert has already been shown.
    func requestLocationAuthorization() {
        UserLocationService.shared.requestLocationServicesPermission()
        UserDefaultsStore.shared.locationServicesPromptDisplayed = true
    }

    /// Sync the BikeRentalStationStore with the API
    /// First the curent nearby stations are fetched from the API. From this data new stations are created and existing stations updated.
    /// Then the rest of the stations in the store are updated
    func fetchFromApi() {

        guard reachability == true else {
            alert = AlertContent.noInternet
            return
        }

        guard userLocation != nil else {
            alert = AlertContent.noLocation
            return
        }

        apiState = .loading

        let mainGroup = DispatchGroup()
        mainGroup.enter()

        Log.i("Starting to update now!")

        DispatchQueue.global(qos: .utility).async { [weak self] in

            guard self != nil else {
                Log.e("Self out of reach")
                mainGroup.leave()
                return
            }

            guard let stationsAlreadyUpdated = self?.fetchNearbyStationsFromApi() else {
                Log.e("Found nil when unwrapping stationsAlreadyUpdated")
                mainGroup.leave()
                return
            }

            Log.i("Nearby fetch done, already updated: \(stationsAlreadyUpdated)")

            let stationsUpdatePending: [String] = BikeRentalStationStore.shared.bikeRentalStationIds.value
                .filter { !stationsAlreadyUpdated.contains($0) }

            self?.updateStationsWithAPI(
                stationsToUpdate: stationsUpdatePending
            )

            mainGroup.leave()

        }

        mainGroup.notify(queue: DispatchQueue.main) {
            Log.i("fetchFromApi() completed")
            self.apiState = .idle
        }
    }

    /// Saves the Bike Rental Station Store
    func saveBikeRentalStationStore() {
        do {
            try BikeRentalStationStore.shared.saveData()
        } catch let error {
            Log.e("Failed to save store: \(error)")
            alert = AlertContent.failedToSaveStore
        }

    }

    func loadBikeRentalStationStore() {
        do {
            try BikeRentalStationStore.shared.loadData()
        } catch let error {
            Log.e("Failed to load store: \(error)")
            alert = AlertContent.failedToLoadStore
        }
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

    private func fetchNearbyStationsFromApi() -> Set<String>? {
        guard let userLocationUnwrapped = self.userLocation else { return nil }

        var stationsAlreadyUpdated: Set<String>?
        let semaphore = DispatchSemaphore(value: 0)

        RoutingAPI.shared.fetchNearbyBikeRentalStations(
            lat: userLocationUnwrapped.coordinate.latitude,
            lon: userLocationUnwrapped.coordinate.longitude,
            radius: nearbyRadius
        ) { (_ bikeRentalStations: [BikeRentalStation]?, _ error: Error?) in

            guard error == nil else {
                DispatchQueue.main.async {
                    self.alert = AlertContent.fetchError
                    semaphore.signal()
                }
                return
            }

            guard let bikeRentalStationsFromApi = bikeRentalStations else {
                DispatchQueue.main.async {
                    self.alert = AlertContent.fetchError
                    semaphore.signal()
                }
                return
            }

            DispatchQueue.main.async {
                BikeRentalStationStore.shared.insertStations(bikeRentalStationsFromApi)
                stationsAlreadyUpdated = Set<String>(bikeRentalStationsFromApi.map { $0.stationId })
                semaphore.signal()
            }
        }

        _ = semaphore.wait(wallTimeout: .distantFuture)

        return stationsAlreadyUpdated
    }

    private func updateStationsWithAPI(
        stationsToUpdate: [String]
    ) {
        Log.i("Upading remaining stations: \(stationsToUpdate)")
        RoutingAPI.shared.fetchBikeRentalStations(
            stationIds: stationsToUpdate
        ) { (_ bikeRentalStations: [BikeRentalStation]?, _ error: Error?) in
            guard error == nil else {

                DispatchQueue.main.async {
                    self.alert = AlertContent.fetchError
                }
                return
            }

            guard let bikeRentalStations = bikeRentalStations else {

                DispatchQueue.main.async {
                    self.alert = AlertContent.fetchError
                }
                return
            }

            DispatchQueue.main.async {
                BikeRentalStationStore.shared.insertStations(bikeRentalStations)
            }
        }
    }

    /// Set value of a given array of Bike Rental Stations
    /// - Parameter valuesToAdd: New values
    /// - Parameter destination: The array where to set the new values
    /// - Parameter animation: If true values are set using withAnimation
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

        if let userLocationUnwrapped = userLocation {
            let insertDistance = bikeRentalStationToInsert.distance(to: userLocationUnwrapped)
            for (index, bikeRentalStation) in bikeRentalStationsArray.enumerated() {
                if insertDistance <= bikeRentalStation.distance(to: userLocationUnwrapped) {
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

    /// Fetch stations from BikeRentalStationStore and sort (if location data available)
    private func fetchStationsFromStoreAndSort(stationIds: [String]) {
        let bikeRentalStationFromIds = userLocation == nil ?
            stationIds
            .compactMap { getRentalStation(stationId: $0) } :
            stationIds
            .compactMap { getRentalStation(stationId: $0) }
            .sorted(by: {
                $0.distance(to: userLocation!) < $1.distance(to: userLocation!)
            })

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

// MARK: - ReachabilityObserverDelegate

extension AppState: ReachabilityObserverDelegate {
    func reachabilityChanged(_ isReachable: Bool) {
        let performFetch = isReachable && reachability != true
        reachability = isReachable
        if performFetch { fetchFromApi() }
    }
}
