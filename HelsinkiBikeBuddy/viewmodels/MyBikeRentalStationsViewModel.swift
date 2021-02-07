//
//  MyBikeRentalStationsViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import CoreData

class MyBikeRentalStationsViewModel {

    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    var bikeRentalStations: [BikeRentalStation] {
        let fetchRequest: NSFetchRequest<BikeRentalStation> = BikeRentalStation.fetchRequest()

        do {
            return try viewContext.fetch(fetchRequest) as [BikeRentalStation]
        } catch {
            return [BikeRentalStation]()
        }
    }
}
