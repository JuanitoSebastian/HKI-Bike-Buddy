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
    @Published var favoriteStations: [BikeRentalStation] = []
    @Published var bikeRentalStations: [BikeRentalStation] = [] {
        willSet {
            favoriteStations = newValue.filter({ $0.favorite })
        }
    }

    private var cancellable: AnyCancellable?

    private let userLocationManager = UserLocationManager.shared

    init(bikeRentalStationPublisher: AnyPublisher<[String: BikeRentalStation], Never> =
            BikeRentalStationStorage.shared.bikeRentalStations.eraseToAnyPublisher()) {
        cancellable = bikeRentalStationPublisher.sink { bikeRentalStations in
            Helper.log("Updating stations")
            self.bikeRentalStations = Array(bikeRentalStations.values)
            self.bikeRentalStations.sort(by: {
                $0.distance(to: self.userLocationManager.userLocation) < $1.distance(to: self.userLocationManager.userLocation)
            })
            Helper.log("DONE!")
        }
    }

}
