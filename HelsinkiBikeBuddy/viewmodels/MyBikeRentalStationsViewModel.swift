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
            favoriteStations = newValue.filter { $0.favorite == true }
        }
    }

    private var cancellable: AnyCancellable?

    init(bikeRentalStationPublisher: AnyPublisher<[String: BikeRentalStation], Never> =
            BikeRentalStationStorage.shared.bikeRentalStations.eraseToAnyPublisher()) {
        cancellable = bikeRentalStationPublisher.sink { bikeRentalStations in
            Helper.log("Updating stations")
            self.bikeRentalStations = Array(bikeRentalStations.values)
        }
    }

}
