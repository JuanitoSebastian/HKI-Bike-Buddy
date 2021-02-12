//
//  BikeRentalStationStorage.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 12.2.2021.
//

import Foundation
import CoreData
import Combine

class BikeRentalStationStorage: NSObject, ObservableObject {

    var bikeRentalStations = CurrentValueSubject<[BikeRentalStation], Never>([])
    private let bikeRentalStationFetchController: NSFetchedResultsController<BikeRentalStation>

    private var moc: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    // Singleton
    static let shared: BikeRentalStationStorage = BikeRentalStationStorage()

    private override init() {
        let fetchRequest: NSFetchRequest<BikeRentalStation> = BikeRentalStation.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        bikeRentalStationFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        bikeRentalStationFetchController.delegate = self

        do {
            try bikeRentalStationFetchController.performFetch()
            bikeRentalStations.value = bikeRentalStationFetchController.fetchedObjects ?? []
        } catch {
            Helper.log("Failed to fetch stations from Core Data")
        }
    }

    func createBikeRentalStation(
        name: String,
        stationId: String,
        lat: Double,
        lon: Double,
        spacesAvailable: Int,
        bikesAvailable: Int,
        allowDropoff: Bool,
        favorite: Bool
    ) {
        let bikeRentalStationToCreate = BikeRentalStation(context: moc)
        bikeRentalStationToCreate.stationId = stationId
        bikeRentalStationToCreate.name = name
        bikeRentalStationToCreate.lat = lat
        bikeRentalStationToCreate.lon = lon
        bikeRentalStationToCreate.bikesAvailable = Int64(bikesAvailable)
        bikeRentalStationToCreate.spacesAvailable = Int64(spacesAvailable)
        bikeRentalStationToCreate.allowDropoff = allowDropoff
        bikeRentalStationToCreate.favorite = favorite
        bikeRentalStationToCreate.fetched = Date()
        saveMoc()
    }

    func deleteBikeRentalStation(_ bikeRentalStationToDelete: BikeRentalStation) {
        moc.delete(bikeRentalStationToDelete)
        saveMoc()
    }

    func saveMoc() {
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            Helper.log("Failed to save MOC: \(error)")
        }
    }

}

extension BikeRentalStationStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let bikeRentalStations = controller.fetchedObjects as? [BikeRentalStation] else { return }
        Helper.log("Context has changed, reloading")
        self.bikeRentalStations.value = bikeRentalStations
    }
}
