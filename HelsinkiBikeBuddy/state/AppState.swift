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
    private var cancellables: Set<AnyCancellable>

    init() {
        self.favouriteRentalStations = []
        self.nearbyRentalStations = []
        self.cancellables = []
        self.mainView = .locationPrompt
        self.notificationState = .none
    }
}

// MARK: - Subscriptions
extension AppState {

    func subscribeToBikeRentalStore() {
        let favouriteCancellable =
            BikeRentalStationStore.shared.favouriteBikeRentalStations.eraseToAnyPublisher().sink { fetched in
            self.favouriteRentalStations = fetched
            // Sort stations from closest to furthest form user
            if let userLocation = UserLocationService.shared.userLocation {
                self.favouriteRentalStations.sort( by: {
                    $0.distance(to: userLocation)
                        < $1.distance(to: userLocation)
                })
            }
        }

        let nearbyCancellable =
            BikeRentalStationStore.shared.nearbyBikeRentalStations.eraseToAnyPublisher().sink { fetched in
            self.nearbyRentalStations = fetched
            // Sort stations from closest to furthest form user
            if let userLocation = UserLocationService.shared.userLocation {
                self.nearbyRentalStations.sort( by: {
                    $0.distance(to: userLocation)
                        < $1.distance(to: userLocation)
                })
            }
        }

        cancellables.insert(favouriteCancellable)
        cancellables.insert(nearbyCancellable)
    }

    func subscribeToUserLocationServiceState() {
        let userLocationServiceCancellable =
            UserLocationService.shared.$locationAuthorization.eraseToAnyPublisher().sink { newValue in
                if newValue == .success {

                }
            }
        cancellables.insert(userLocationServiceCancellable)
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

}

// MARK: - UI Functions
extension AppState {

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
extension AppState {

    enum MainViewState {
        case rentalStations
        case locationPrompt
    }

    enum NotificationState {
        case none
        case notification(String)
        case error(String)
    }
}
