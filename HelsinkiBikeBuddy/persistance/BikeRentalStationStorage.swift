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

    private var stations = CurrentValueSubject<[BikeRentalStation], Never>([])
    var bikeRentalStations = CurrentValueSubject<[String: BikeRentalStation], Never>([:])
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
            guard let bikeRentalStationsArray = bikeRentalStationFetchController.fetchedObjects else { return }
            for bikeRentalStation in bikeRentalStationsArray {
                bikeRentalStations.value[bikeRentalStation.id] = bikeRentalStation
            }
        } catch {
            Helper.log("Failed to fetch stations from Core Data")
        }
    }
    // swiftlint:disable:next function_parameter_count
    func createBikeRentalStation(
        name: String,
        stationId: String,
        lat: Double,
        lon: Double,
        spacesAvailable: Int,
        bikesAvailable: Int,
        allowDropoff: Bool,
        favorite: Bool,
        state: Bool
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
        bikeRentalStationToCreate.state = state
    }

    func bikeRentalStationFromCoreData(stationId: String) -> BikeRentalStation? {
        let fetchRequest: NSFetchRequest<BikeRentalStation> = NSFetchRequest(entityName: "BikeRentalStation")
        fetchRequest.predicate = NSPredicate(format: "stationId = %@", stationId)

        do {
            let results = try moc.fetch(fetchRequest)
            if let bikeRentalStation = results.first {
                return bikeRentalStation
            }
        } catch {
            Helper.log("Failed to fetch from MOC: \(error)")
        }

        return nil

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

// FIX: This is called multiple times and freezes
extension BikeRentalStationStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedBikeRentalStations = controller.fetchedObjects as? [BikeRentalStation] else { return }
        var newBikeRentalStations: [String: BikeRentalStation] = [:]
        for bikeRentalStation in fetchedBikeRentalStations {
            newBikeRentalStations[bikeRentalStation.id] = bikeRentalStation
        }
        self.bikeRentalStations.value = newBikeRentalStations
    }
}
