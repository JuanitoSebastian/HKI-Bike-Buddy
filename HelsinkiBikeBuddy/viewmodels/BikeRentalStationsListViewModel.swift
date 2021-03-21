//
//  NearbyBikeRentalStationsViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import Foundation
import Combine

class BikeRentalStationsListViewModel: ObservableObject {

    @Published var bikeRentalStations: [RentalStation] = []
    var stationListType: BikeRentalStationListType

    private var cancellable: AnyCancellable?

    var state: BikeRentalStationListViewState {
        if bikeRentalStations.isEmpty {

            if stationListType == .favorite {
                return .empty
            }

            if BikeRentalService.shared.apiState == .loading {
                return .loading
            }

        }
        return .stationsLoaded
    }

    var listEmptyText: String {
        switch stationListType {
        case .favorite:
            return "Add stations here by tapping the heart 💛"
        case .nearby:
            return "No bike rental stations nearby.\nYou can try increasing the maximum distance to nearby stations from the settings."
        }
    }

    init(publisher: AnyPublisher<[RentalStation], Never>, stationListType: BikeRentalStationListType) {
        self.stationListType = stationListType
        self.cancellable = publisher.sink { fetched in
            self.bikeRentalStations = fetched
            self.bikeRentalStations.sort( by: {
                $0.distance(to: UserLocationManager.shared.userLocation)
                    < $1.distance(to: UserLocationManager.shared.userLocation)
            })
        }
    }
}

enum BikeRentalStationListViewState {
    case stationsLoaded
    case empty
    case loading
}

enum BikeRentalStationListType {
    case favorite
    case nearby
}
