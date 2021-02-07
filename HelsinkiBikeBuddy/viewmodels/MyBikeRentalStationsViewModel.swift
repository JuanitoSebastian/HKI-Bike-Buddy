//
//  MyBikeRentalStationsViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import CoreData

class MyBikeRentalStationsViewModel: ObservableObject {

    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataHasChanged),
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil
        )
    }

    var bikeRentalStations: [BikeRentalStation] {
        let fetchRequest: NSFetchRequest<BikeRentalStation> = BikeRentalStation.fetchRequest()

        do {
            return try viewContext.fetch(fetchRequest) as [BikeRentalStation]
        } catch {
            return [BikeRentalStation]()
        }
    }

    @objc
    func dataHasChanged() {
        objectWillChange.send()
    }
}
