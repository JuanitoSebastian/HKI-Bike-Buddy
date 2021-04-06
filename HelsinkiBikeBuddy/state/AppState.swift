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

    @Published private(set) var favouriteRentalStations: [RentalStation]
    @Published private(set) var nearbyRentalStations: [RentalStation]
    @Published private(set) var mainView: MainViewState
    @Published private(set) var notificationState: NotificationState
    @Published var tabBarSelection: TabBarSelection
    private var cancellables: Set<AnyCancellable>

    init() {
        self.favouriteRentalStations = []
        self.nearbyRentalStations = []
        self.cancellables = []
        self.mainView = .locationPrompt
        self.notificationState = .none
        self.tabBarSelection = .nearbyStations
        subscribeToUserLocationServiceState()
        subscribeToBikeRentalStore()
    }
}

// MARK: - Subscriptions
extension AppState {

    func subscribeToBikeRentalStore() {
        let storeSubscription =
            BikeRentalStationStore.shared.bikeRentalStationIds.eraseToAnyPublisher().sink { fetched in

                self.nearbyRentalStations = fetched
                    .map({ (stationId: String) in
                        return self.getRentalStation(stationId: stationId)
                    })
                    .filter { $0.isNearby }

                self.favouriteRentalStations = fetched
                    .map({ (stationId: String) in
                        return self.getRentalStation(stationId: stationId)
                    })
                    .filter { $0.favourite }

            }

        cancellables.insert(storeSubscription)
    }

    func subscribeToUserLocationServiceState() {
        let userLocationServiceCancellable =
            UserLocationService.shared.$locationAuthorization.eraseToAnyPublisher().sink { newValue in
                switch newValue {
                case .success:
                    self.mainView = .rentalStations

                case .denied:
                    self.mainView = .locationPrompt
                }
            }
        cancellables.insert(userLocationServiceCancellable)
    }

    private func sortRentalStation(rentalStations: [RentalStation]) -> [RentalStation] {
        if let userLocation = UserLocationService.shared.userLocation {
            return rentalStations.sorted( by: {
                $0.distance(to: userLocation)
                    < $1.distance(to: userLocation)
            })
        } else {
            return rentalStations
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

    func getRentalStation(stationId: String) -> RentalStation {
        BikeRentalStationStore.shared.bikeRentalStations[stationId]!
    }

    func favouriteRentalStation(rentalStation: RentalStation) -> RentalStation? {
        return BikeRentalStationStore.shared.favouriteStation(rentalStation: rentalStation)
    }

    func unFavouriteRentalStation(rentalStation: RentalStation) -> RentalStation? {
        return BikeRentalStationStore.shared.unfavouriteStation(rentalStation: rentalStation)
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

}

// MARK: - Enums

enum MainViewState {
    case rentalStations
    case locationPrompt
}

enum NotificationState {
    case none
    case notification(String)
    case error(String)
}

enum TabBarSelection: Int, Codable {
    case nearbyStations
    case myStations
}
