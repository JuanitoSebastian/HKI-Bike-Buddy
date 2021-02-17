//
//  MyBikeRentalStationsViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import CoreData
import Combine

class MyBikeRentalStationsViewModel: ObservableObject {
    @Published var favoriteStations: [RentalStation] = []
    @Published var bikeRentalStations: [RentalStation] = [] {
        willSet {
            favoriteStations = newValue.filter({ $0.favorite })
        }
    }

    private var cancellable: AnyCancellable?

    private let userLocationManager = UserLocationManager.shared

    init(bikeRentalStationPublisher: AnyPublisher<[RentalStation], Never> =
            BikeRentalStationStorage.shared.stationsManaged.eraseToAnyPublisher()) {
        cancellable = bikeRentalStationPublisher.sink { bikeRentalStations in
            Helper.log("Updating stations")
            self.bikeRentalStations = bikeRentalStations
            self.bikeRentalStations.sort(by: {
                $0.distance(to: self.userLocationManager.userLocation) < $1.distance(to: self.userLocationManager.userLocation)
            })
            Helper.log("DONE!")
        }
    }

}
