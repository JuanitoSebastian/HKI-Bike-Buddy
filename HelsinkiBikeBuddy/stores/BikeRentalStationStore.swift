//
//  BikeRentalStationStorage.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 12.2.2021.
//

import Foundation
import CoreData
import Combine

// MARK: - Initiation of class
/**
 Handles creation, editing and storage of RentalStations. Class is accessed using the singleton instance: shared.
 The testing instance of the class doees not persistently save the ManagedBikeRentalStations.

 Class conforms to NSFetchedResultsControllerDelegate protocol enabling use of NSFetchedResultsController.
 With NSFetchedResultsController we can subscribe to listen for changes in the MOC. This way when
 ManagedBikeRentalStation objects values are updated or new ManagedBikeRentalStations are created
 we can reload the objects from the store. This way the persistent store and the application always stay in sync.
 */
class BikeRentalStationStore: NSObject {
    /// Singleton instance of class
    static let shared = BikeRentalStationStore()

    private(set) var bikeRentalStations: [String: RentalStation] = [:]
    let bikeRentalStationIds = CurrentValueSubject<[String], Never>([])
    private let fetchController: NSFetchedResultsController<ManagedBikeRentalStation>

    var managedObjectContext: NSManagedObjectContext {
        fetchController.managedObjectContext
    }

    /// Initiates the NSFetchedResultsController and performs initial fetch
    /// of ManagedBikeRentalStations from persistent store.
    /// If tests are running the correct Managed Object Context is fetched
    override private init() {
        let fetchRequest: NSFetchRequest<ManagedBikeRentalStation> = ManagedBikeRentalStation.fetchRequest()
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
        fetchStationsFromPersistentStore()

    }

    /// Fetches stations from Core Data persistent store
    private func fetchStationsFromPersistentStore() {
        do {
            try fetchController.performFetch()
            guard let bikeRentalStationsArray = fetchController.fetchedObjects else { return }

            for fetchedStation in bikeRentalStationsArray {
                bikeRentalStations[fetchedStation.stationId] = fetchedStation
            }

            bikeRentalStationIds.value = bikeRentalStationsArray
                .map { $0.stationId }

        } catch {
            Helper.log("Failed to fetch stations from Core Data")
        }
    }

}

// MARK: - Creation / Editing of Rental Stations
extension BikeRentalStationStore {

    func saveManagedObjectContext() {
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            Helper.log("Failed to save MOC: \(error)")
        }
    }

    private func removeFromManagedObjectContext(_ bikeRentalStationToDelete: ManagedBikeRentalStation) {
        Log.i("Deleting ManagedStation: \(bikeRentalStationToDelete.name)")
        managedObjectContext.delete(bikeRentalStationToDelete)
    }

    func addStations(rentalStations: [RentalStation]) {
        for rentalStation in rentalStations {
            bikeRentalStations[rentalStation.stationId] = rentalStation
        }
        bikeRentalStationIds.value.append(contentsOf: rentalStations.map { $0.stationId })
    }

    /// Converts a UnmanagedBikeRentalStation to a ManagedBikeRentalStation
    /// - Parameter rentalStation: The rental station that should be converted to a ManagedBikeRentalStation
    /// - Returns: ManagedBikeRentalStation. If rentalStation is already managed it is returned as is.
    private func toManagedBikeRentalStation(rentalStation: RentalStation) -> RentalStation {
        if rentalStation is ManagedBikeRentalStation { return (rentalStation as? ManagedBikeRentalStation)! }
        let managedBikeRentalStation: RentalStation = ManagedBikeRentalStation(
            context: managedObjectContext,
            stationId: rentalStation.stationId,
            name: rentalStation.name,
            lat: rentalStation.lat,
            lon: rentalStation.lon,
            state: rentalStation.state,
            allowDropff: rentalStation.allowDropoff,
            spacesAvailable: rentalStation.spacesAvailable,
            bikesAvailable: rentalStation.bikesAvailable,
            fetched: rentalStation.fetched
        )
        return managedBikeRentalStation
    }

    /// Converts a ManagedBikeRentalStation to an UnmanagedBikeRentalStation
    /// - Parameter rentalStation: The rental station that should be converted to an UnmanagedBikeRentalStation
    /// - Returns: UnmanagedBikeRentalStation. If rentalStation is already unmanaged it is returned as is.
    private func toUnmanagedBikeRentalStation(rentalStation: RentalStation) -> UnmanagedBikeRentalStation {
        if rentalStation is UnmanagedBikeRentalStation { return (rentalStation as? UnmanagedBikeRentalStation)! }
        let unmanagedBikeRentalStation = UnmanagedBikeRentalStation(
            stationId: rentalStation.stationId,
            name: rentalStation.name,
            allowDropoff: rentalStation.allowDropoff,
            bikesAvailable: rentalStation.bikesAvailable,
            fetched: rentalStation.fetched,
            lat: rentalStation.lat,
            lon: rentalStation.lon,
            spacesAvailable: rentalStation.spacesAvailable,
            state: rentalStation.state
        )
        Log.i("Created an unmanaged rentalStation")
        return unmanagedBikeRentalStation
    }

    /**
     Fetches a BikeRentalStation from the MOC.
     - Parameter stationId: The StationId of the BikeRentalStation that will be retrieved.
     - Returns: The BikeRentalStation corresponding to the provided stationId.
     If a station is not found nil is returned.
     */
    func bikeRentalStationFromCoreData(stationId: String?) -> ManagedBikeRentalStation? {
        guard let stationIdUnwrapped = stationId else { return nil }
        let fetchRequest: NSFetchRequest<ManagedBikeRentalStation> = ManagedBikeRentalStation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "stationId = %@", stationIdUnwrapped)

        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            if let bikeRentalStation = results.first {
                return bikeRentalStation
            }
        } catch {
            Helper.log("Failed to fetch from MOC: \(error)")
        }
        return nil
    }

    /**
     Converts an UnmanagedBikeRentalStation to a ManagedBikeRentalStation (marking it as a favourite & adding it to MOC)
     and replaces the Unmanaged object in stationsNearby with the new managed one.
     - Parameter rentalStation: The RentalStation to favourite
     */
    func favouriteStation(rentalStation: RentalStation) -> RentalStation? {
        if rentalStation is ManagedBikeRentalStation { return rentalStation }
        let managedStation = toManagedBikeRentalStation(rentalStation: rentalStation)
        bikeRentalStations[managedStation.stationId] = managedStation
        bikeRentalStationIds.send(bikeRentalStationIds.value)
        saveManagedObjectContext()
        return managedStation

    }

    /**
     Unfavourites a RentalStation (removing it from MOC).
     If the station is nearby it is converted to an UnmanagedBikeRentalStations and added to stationsNearby
     - Parameter rentalStation: The RentalStation to unfavourite
     */
    func unfavouriteStation(rentalStation: RentalStation) -> RentalStation? {
        if rentalStation is UnmanagedBikeRentalStation { return rentalStation }
        let stationId = rentalStation.stationId

        // swiftlint:disable force_cast
        removeFromManagedObjectContext(rentalStation as! ManagedBikeRentalStation)
        // swiftlint:enable force_cast

        if rentalStation.isNearby {
            bikeRentalStations[stationId] = toUnmanagedBikeRentalStation(
                rentalStation: rentalStation
            )
            bikeRentalStationIds.send(bikeRentalStationIds.value)
        } else {
            bikeRentalStations.removeValue(forKey: stationId)
            bikeRentalStationIds.value = removeStationIdFromList(stationId, from: bikeRentalStationIds.value)
        }

        saveManagedObjectContext()
        return bikeRentalStations[stationId]
    }

    private func removeStationIdFromList(_ stationIdToRemove: String, from: [String]) -> [String] {
        var stationsEdited = from
        for (index, stationId) in stationsEdited.enumerated()
        where stationIdToRemove == stationId {
            stationsEdited.remove(at: index)
        }
        return stationsEdited
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension BikeRentalStationStore: NSFetchedResultsControllerDelegate {

    /// Subscribig to listen for chances in the Managed Object Context.
    /// After changes have been made the ManagedBikeRentalStations are reloaded to keep MOC and store in sync.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /*
         guard let fetchedBikeRentalStations = controller.fetchedObjects as? [RentalStation] else { return }
         self.favouriteBikeRentalStations.value = fetchedBikeRentalStations
         */
    }

}
