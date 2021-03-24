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

 Class conforms to NSFetchedResultsControllerDelegate protocol enabling use of NSFetchedResultsController.
 With NSFetchedResultsController we can subscribe to listen for changes in the MOC. This way when
 ManagedBikeRentalStation objects values are updated or new ManagedBikeRentalStations are created
 we can reload the objects from the store. This way the persistent store and the application always stay in sync.
 */
class BikeRentalStationStore: NSObject, ObservableObject {
    /// Singleton instance of class
    static let shared: BikeRentalStationStore = BikeRentalStationStore()

    let favouriteBikeRentalStations = CurrentValueSubject<[RentalStation], Never>([])
    let nearbyBikeRentalStations = CurrentValueSubject<[RentalStation], Never>([])
    private let fetchController: NSFetchedResultsController<ManagedBikeRentalStation>

    var managedObjectContext: NSManagedObjectContext {
        fetchController.managedObjectContext
    }

    /// Initiates the NSFetchedResultsController and performs initial fetch
    /// of ManagedBikeRentalStations from persistent store.
    private override init() {
        let fetchRequest: NSFetchRequest<ManagedBikeRentalStation> = ManagedBikeRentalStation.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: PersistenceController.shared.container.viewContext,
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

    /**
     Creates a ManagedBikeRentalStation and returns it
     - Returns: The ManagedBikeRentalStation created from the parameters
     */
    // swiftlint:disable:next function_parameter_count
    private func createManagedBikeRentalStation(
        name: String,
        stationId: String,
        lat: Double,
        lon: Double,
        spacesAvailable: Int64,
        bikesAvailable: Int64,
        allowDropoff: Bool,
        favourite: Bool,
        state: Bool,
        fetched: Date
    ) -> ManagedBikeRentalStation {
        let managedBikeRentalStation = ManagedBikeRentalStation(context: managedObjectContext)
        managedBikeRentalStation.stationId = stationId
        managedBikeRentalStation.name = name
        managedBikeRentalStation.lat = lat
        managedBikeRentalStation.lon = lon
        managedBikeRentalStation.bikesAvailable = bikesAvailable
        managedBikeRentalStation.spacesAvailable = spacesAvailable
        managedBikeRentalStation.allowDropoff = allowDropoff
        managedBikeRentalStation.favorite = favourite
        managedBikeRentalStation.fetched = fetched
        managedBikeRentalStation.state = state
        return managedBikeRentalStation
    }

    /**
     Creates an UnmanagedBikeRentalStation.
     - Returns: The UnmanagedBikeRentalStation created from the parameters
     */
    // swiftlint:disable:next function_parameter_count
    private func createUnmanagedBikeRentalStation(
        name: String,
        stationId: String,
        lat: Double,
        lon: Double,
        spacesAvailable: Int64,
        bikesAvailable: Int64,
        allowDropoff: Bool,
        favourite: Bool,
        state: Bool,
        fetched: Date
    ) -> UnmanagedBikeRentalStation {
        let unmanagedBikeRentalStation = UnmanagedBikeRentalStation(
            stationId: stationId,
            name: name,
            allowDropoff: allowDropoff,
            bikesAvailable: bikesAvailable,
            favorite: false,
            fetched: fetched,
            lat: lat,
            lon: lon,
            spacesAvailable: spacesAvailable,
            state: state
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
                stationToRemove: rentalStation,
                stations: nearbyBikeRentalStations.value
            )
            let managedStation = createManagedBikeRentalStation(
                name: rentalStation.name,
                stationId: rentalStation.stationId,
                lat: rentalStation.lat,
                lon: rentalStation.lon,
                spacesAvailable: rentalStation.spacesAvailable,
                bikesAvailable: rentalStation.bikesAvailable,
                allowDropoff: rentalStation.allowDropoff,
                favourite: true,
                state: rentalStation.state,
                fetched: rentalStation.fetched
            )
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
        let distance = rentalStation.distance(to: UserLocationService.shared.userLocation)

        if distance <= Double(UserDefaultsService.shared.nearbyDistance) {
            var stationsEdited = removeStationFromList(stationToRemove: rentalStation, stations: nearbyBikeRentalStations.value)
            let unmanaged = createUnmanagedBikeRentalStation(
                name: rentalStation.name,
                stationId: rentalStation.stationId,
                lat: rentalStation.lat,
                lon: rentalStation.lon,
                spacesAvailable: rentalStation.spacesAvailable,
                bikesAvailable: rentalStation.bikesAvailable,
                allowDropoff: rentalStation.allowDropoff,
                favourite: false,
                state: rentalStation.state,
                fetched: rentalStation.fetched
            )
            stationsEdited.append(unmanaged)
            nearbyBikeRentalStations.value = stationsEdited
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
    private func removeStationFromList(stationToRemove: RentalStation, stations: [RentalStation]) -> [RentalStation] {
        var stationsEdited = stations
        for (index, rentalStation) in stationsEdited.enumerated()
        where rentalStation.stationId == stationToRemove.stationId {
            stationsEdited.remove(at: index)
        }
        return stationsEdited
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension BikeRentalStationStore: NSFetchedResultsControllerDelegate {

    // When content in the MOC changes the value of stationsFavourite is updated (overwritten) with new values from MOC.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedBikeRentalStations = controller.fetchedObjects as? [RentalStation] else { return }
        self.favouriteBikeRentalStations.value = fetchedBikeRentalStations
    }

}
