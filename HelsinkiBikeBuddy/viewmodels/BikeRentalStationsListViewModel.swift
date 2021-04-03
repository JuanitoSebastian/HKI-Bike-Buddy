//
//  NearbyBikeRentalStationsViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import Foundation
import Combine

/// ViewModel for the list of bike rental stations.
class BikeRentalStationsListViewModel: ObservableObject {

    @Published var rentalStations: [RentalStation] = []
    var stationListType: BikeRentalStationListType
    private var cancellable: AnyCancellable?

    var state: BikeRentalStationListViewState {
        if rentalStations.isEmpty {
            if BikeRentalStationApiService.shared.apiOperationState == .loading && stationListType == .nearby {
                return .loading
            }
            return .empty
        }
        return .stationsLoaded
    }

    var listEmptyText: String {
        switch stationListType {
        case .favourite:
            return "You can add stations here by favouriting them 💗"
        case .nearby:
            return "No bike rental stations nearby"
        }
    }

    /**
     Initiate an instance of the BikeRentalStationsListViewModel.
     - Parameter publisher: Publisher of the list of RentalStations
     - Parameter stationListType: Determines if these stations are nearby stations or favourites?
     */
    init(publisher: AnyPublisher<[RentalStation], Never>, stationListType: BikeRentalStationListType) {
        self.stationListType = stationListType
        self.cancellable = publisher.sink { fetched in
            self.rentalStations = fetched
            // Sort stations from closest to furthest form user
            if let userLocation = UserLocationService.shared.userLocation {
                self.rentalStations.sort( by: {
                    $0.distance(to: userLocation)
                        < $1.distance(to: userLocation)
                })
            }
        }
    }
}

enum BikeRentalStationListViewState {
    case stationsLoaded
    case empty
    case loading
}

enum BikeRentalStationListType {
    case favourite
    case nearby
}
