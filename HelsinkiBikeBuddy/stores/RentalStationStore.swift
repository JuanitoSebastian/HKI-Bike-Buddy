//
//  RentalStationStore.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.4.2021.
//

import Foundation
import CoreData
import Combine

// MARK: - Initiation of class

class RentalStationStore: NSObject {
    /// Singleton instance of class
    static let shared = RentalStationStore()

    private(set) var bikeRentalStations: [String: BikeRentalStation] = [:]
    private var favouriteRecords: [String: BikeRentalStationRecord] = [:]
    private let fetchController: NSFetchedResultsController<BikeRentalStationRecord>
    public let bikeRentalStationIds = CurrentValueSubject<[String], Never>([])

    private var managedObjectContext: NSManagedObjectContext {
        fetchController.managedObjectContext
    }

    /// Initiates the NSFetchedResultsController and performs initial fetch
    /// of ManagedBikeRentalStations from persistent store.
    /// If tests are running the correct Managed Object Context is fetched
    override private init() {
        let fetchRequest: NSFetchRequest<BikeRentalStationRecord> = BikeRentalStationRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        // Check for testing flag
        #if DEBUG
        let managedObjectContextToUse = Helper.isRunningTests() ?
            PersistenceController.testing.container.viewContext :
            PersistenceController.shared.container.viewContext
        #else
        let managedObjectContextToUse = PersistenceController.shared.container.viewContext
        #endif
        fetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContextToUse,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        fetchController.delegate = self
        fectchRecordsFromStore()
        createStationsFromRecords()
    }

    private func fectchRecordsFromStore() {
        do {
            try fetchController.performFetch()
            guard let recordsArray = fetchController.fetchedObjects else { return }
            favouriteRecords = recordsArray.reduce([String: BikeRentalStationRecord]()) { (dict, record) -> [String: BikeRentalStationRecord] in
                var dict = dict
                dict[record.stationId] = record
                return dict
            }
        } catch {
            Log.e("Failed to fetch MOC: \(error)")
        }
    }

    private func createStationsFromRecords() {
        var bikeRentalStationsFromMoc: [BikeRentalStation] = []
        for stationRecord in favouriteRecords.values {
            let bikeRentalStation = BikeRentalStation(
                stationId: stationRecord.stationId,
                name: stationRecord.name
            )
            bikeRentalStationsFromMoc.append(bikeRentalStation)
        }
        addBikeRentalStations(bikeRentalStationsFromMoc)
    }
}

// MARK: - Interaction with the store
extension RentalStationStore {

    var favouritesEmpty: Bool {
        return favouriteRecords.isEmpty
    }

    func addBikeRentalStations(_ stationsToAdd: [BikeRentalStation]) {
        var stationIds: [String] = bikeRentalStationIds.value
        for rentalStationToAdd in stationsToAdd {
            bikeRentalStations[rentalStationToAdd.stationId] = rentalStationToAdd
            stationIds.append(rentalStationToAdd.stationId)
        }
        bikeRentalStationIds.value = stationIds
    }

    func markAsFavourite(_ bikeRentalStation: BikeRentalStation) {
        Log.i("Favouriting: \(bikeRentalStation.name) (\(bikeRentalStation.stationId)")
        bikeRentalStation.favourite = true
        let record = BikeRentalStationRecord(context: managedObjectContext)
        record.stationId = bikeRentalStation.stationId
        record.name = bikeRentalStation.name
        saveManagedObjectContext()
        favouriteRecords[bikeRentalStation.stationId] = record
    }

    func markAsNonfavourite(_ bikeRentalStation: BikeRentalStation) {
        if bikeRentalStation.favourite != true { return }

        Log.i("Unfavouriting: \(bikeRentalStation.name) (\(bikeRentalStation.stationId)")
        bikeRentalStation.favourite = false

        if let recordToDelete = favouriteRecords[bikeRentalStation.stationId] {
            favouriteRecords.removeValue(forKey: bikeRentalStation.stationId)
            removeFromManagedObjectContext(recordToDelete)
            saveManagedObjectContext()
        }

        if !bikeRentalStation.isNearby {
            bikeRentalStationIds.value = removeStationId(
                stationId: bikeRentalStation.stationId,
                from: bikeRentalStationIds.value
            )
            bikeRentalStations.removeValue(forKey: bikeRentalStation.stationId)
        }
    }

    func isStationFavourite(stationId: String) -> Bool {
        return favouriteRecords[stationId] != nil ? true : false
    }

    private func removeStationId(stationId: String, from: [String]) -> [String] {
        return from.filter { $0 != stationId }
    }
}

// MARK: - NSFetchedResultsControllerDelegate & managing of persistance
extension RentalStationStore: NSFetchedResultsControllerDelegate {

    func saveManagedObjectContext() {
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            Log.e("Failed to save MOC: \(error)")
        }
    }

    private func removeFromManagedObjectContext(_ recordToDelete: BikeRentalStationRecord) {
        Log.i("Deleting record from MOC: \(recordToDelete.name)")
        managedObjectContext.delete(recordToDelete)
    }

    /// Subscribig to listen for chances in the Managed Object Context.
    /// After changes have been made the ManagedBikeRentalStations are reloaded to keep MOC and store in sync.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let recordsArray = fetchController.fetchedObjects else { return }
        favouriteRecords = recordsArray.reduce([String: BikeRentalStationRecord]()) { (dict, record) -> [String: BikeRentalStationRecord] in
            var dict = dict
            dict[record.stationId] = record
            return dict
        }
    }

}
