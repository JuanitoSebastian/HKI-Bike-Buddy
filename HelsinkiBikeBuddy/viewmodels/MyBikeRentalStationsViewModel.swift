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
            Helper.log("Updating stations to: \(newValue)")
            favoriteStations = newValue.filter { $0.favorite == true }
        }
    }

    private var cancellable: AnyCancellable?

    init(bikeRentalStationPublisher: AnyPublisher<[BikeRentalStation], Never> =
            BikeRentalStationStorage.shared.bikeRentalStations.eraseToAnyPublisher()) {
        cancellable = bikeRentalStationPublisher.sink { bikeRentalStations in
            Helper.log("Updating stations")
            self.bikeRentalStations = bikeRentalStations
        }
    }

}

/*
 class MyBikeRentalStationsViewModel: ObservableObject {

     let viewContext: NSManagedObjectContext

     init(viewContext: NSManagedObjectContext) {
         self.viewContext = viewContext
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(dataHasChanged),
             name: Notification.Name.NSManagedObjectContextObjectsDidChange,
             object: nil
         )
     }

     var bikeRentalStations: [BikeRentalStation] {
         Helper.log("Fetching stations from viewmodel")
         let fetchRequest: NSFetchRequest<BikeRentalStation> = BikeRentalStation.fetchRequest()

         do {
             let stations = try viewContext.fetch(fetchRequest) as [BikeRentalStation]
             return stations
         } catch {
             return [BikeRentalStation]()
         }
     }

     @objc
     func dataHasChanged() {
         objectWillChange.send()
     }
 }

 */
