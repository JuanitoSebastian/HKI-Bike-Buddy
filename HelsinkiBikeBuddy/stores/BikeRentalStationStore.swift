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

    let favouriteBikeRentalStations = CurrentValueSubject<[RentalStation], Never>([])
    let nearbyBikeRentalStations = CurrentValueSubject<[RentalStation], Never>([])
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
            self.favouriteBikeRentalStations.value = bikeRentalStationsArray
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
        managedObjectContext.delete(bikeRentalStationToDelete)
    }

    /// Converts a UnmanagedBikeRentalStation to a ManagedBikeRentalStation
    /// - Parameter rentalStation: The rental station that should be converted to a ManagedBikeRentalStation
    /// - Returns: ManagedBikeRentalStation. If rentalStation is already managed it is returned as is.
    private func toManagedBikeRentalStation(rentalStation: RentalStation) -> ManagedBikeRentalStation {
        if rentalStation is ManagedBikeRentalStation { return (rentalStation as? ManagedBikeRentalStation)! }
        let managedBikeRentalStation = ManagedBikeRentalStation(context: managedObjectContext)
        managedBikeRentalStation.stationId = rentalStation.stationId
        managedBikeRentalStation.name = rentalStation.name
        managedBikeRentalStation.lat = rentalStation.lat
        managedBikeRentalStation.lon = rentalStation.lon
        managedBikeRentalStation.spacesAvailable = rentalStation.spacesAvailable
        managedBikeRentalStation.bikesAvailable = rentalStation.bikesAvailable
        managedBikeRentalStation.allowDropoff = rentalStation.allowDropoff
        managedBikeRentalStation.state = rentalStation.state
        managedBikeRentalStation.fetched = rentalStation.fetched
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
        return unmanagedBikeRentalStation
    }

    /**
     Fetches a BikeRentalStation from the MOC.
     - Parameter stationId: The StationId of the BikeRentalStation that will be retrieved.
     - Returns: The BikeRentalStation corresponding to the provided stationId.
     If a station is not found nil is returned.
     */
    func bikeRentalStationFromCoreData(stationId: String) -> ManagedBikeRentalStation? {
        let fetchRequest: NSFetchRequest<ManagedBikeRentalStation> = ManagedBikeRentalStation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "stationId = %@", stationId)

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
    func favouriteStation(rentalStation: RentalStation) {
        if rentalStation is UnmanagedBikeRentalStation {
            var stationsNearbyEdited = removeStationFromList(
                station: rentalStation,
                from: nearbyBikeRentalStations.value
            )
            let managedStation = toManagedBikeRentalStation(rentalStation: rentalStation)
            stationsNearbyEdited.append(managedStation)
            nearbyBikeRentalStations.value = stationsNearbyEdited
            saveManagedObjectContext()
        }
    }

    /**
     Unfavourites a RentalStation (removing it from MOC).
     If the station is nearby it is converted to an UnmanagedBikeRentalStations and added to stationsNearby
     - Parameter rentalStation: The RentalStation to unfavourite
     */
    func unfavouriteStation(rentalStation: RentalStation) {
        if rentalStation is UnmanagedBikeRentalStation { return }
        print(rentalStation.name)
        if let userLocation = UserLocationService.shared.userLocation {
            let distance = rentalStation.distance(to: userLocation)

            if distance <= Double(UserDefaultsService.shared.nearbyDistance) {
                Helper.log("Adding back, distance: \(distance)")
                var stationsEdited = removeStationFromList(station: rentalStation, from: nearbyBikeRentalStations.value)
                let unmanagedRentalStation = toUnmanagedBikeRentalStation(rentalStation: rentalStation)
                stationsEdited.append(unmanagedRentalStation)
                nearbyBikeRentalStations.value = stationsEdited
            }
        }

        // swiftlint:disable force_cast
        removeFromManagedObjectContext(rentalStation as! ManagedBikeRentalStation)
        // swiftlint:enable force_cast
        saveManagedObjectContext()
    }

    /**
     Removes a RentalStation from a list of RentalStations.
     If stationToRemove is not found in stations it is returned untouched.
     - Parameter stationToRemove: The RentalStation that should be be removed.
     - Parameter stations: The list which will be edited
     - Returns: An edited list of the provided RentalStations.
     */
    private func removeStationFromList(station: RentalStation, from: [RentalStation]) -> [RentalStation] {
        var stationsEdited = from
        for (index, rentalStation) in stationsEdited.enumerated()
        where rentalStation.stationId == station.stationId {
            stationsEdited.remove(at: index)
        }
        return stationsEdited
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension BikeRentalStationStore: NSFetchedResultsControllerDelegate {

    /// Subscribig to listen for chances in the Managed Object Context. After changes have been made the ManagedBikeRentalStations are reloaded to keep MOC and store in sync.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedBikeRentalStations = controller.fetchedObjects as? [RentalStation] else { return }
        self.favouriteBikeRentalStations.value = fetchedBikeRentalStations
    }

}
