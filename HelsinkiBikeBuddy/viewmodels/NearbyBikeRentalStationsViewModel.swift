//
//  NearbyBikeRentalStationsViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import Foundation
import Combine

class NeabyBikeRentalStationsViewModel: ObservableObject {

    @Published var nearbyBikeRentalStations: [RentalStation] = []

    private var cancellable: AnyCancellable?

    public static let shared = NeabyBikeRentalStationsViewModel()

    init(nearbyBikeRentalStationPublisher: AnyPublisher<[RentalStation], Never>
            = BikeRentalStationStorage.shared.stationsNearby.eraseToAnyPublisher()) {
        cancellable = BikeRentalStationStorage.shared.stationsNearby.sink { fetched in
            self.nearbyBikeRentalStations = fetched
            self.nearbyBikeRentalStations.sort( by: {
                $0.distance(to: UserLocationManager.shared.userLocation) < $1.distance(to: UserLocationManager.shared.userLocation)
            })
        }
    }

}
