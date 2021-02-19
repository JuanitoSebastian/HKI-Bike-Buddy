//
//  FavoriteBikeRentalStationViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import Foundation
import Combine

class FavoriteBikeRentalStationViewModel: ObservableObject {

    @Published var favoriteBikeRentalStations: [RentalStation] = []

    private var cancellable: AnyCancellable?

    public static let shared = FavoriteBikeRentalStationViewModel()

    init(favoriteBikeRentalStationPublisher: AnyPublisher<[RentalStation], Never> = BikeRentalStationStorage.shared.stationsFavorite.eraseToAnyPublisher()) {
        cancellable = BikeRentalStationStorage.shared.stationsFavorite.sink { fetched in
            self.favoriteBikeRentalStations = fetched
            self.favoriteBikeRentalStations.sort(by: {
                $0.distance(
                    to: UserLocationManager.shared.userLocation) < $1.distance(to: UserLocationManager.shared.userLocation)
            })
        }
    }

}
