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

    private var cancellable: AnyCancellable?

    var state: BikeRentalStationListViewState {
        if bikeRentalStations.isEmpty {
            return .empty
        }
        return .stationsLoaded
    }

    init(publisher: AnyPublisher<[RentalStation], Never>) {
        cancellable = publisher.sink { fetched in
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
