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

    var stationsFavorite = CurrentValueSubject<[RentalStation], Never>([])
    var stationsNearby = CurrentValueSubject<[RentalStation], Never>([])
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
            self.stationsFavorite.value = bikeRentalStationsArray
        } catch {
            Helper.log("Failed to fetch stations from Core Data")
        }
    }
    // swiftlint:disable:next function_parameter_count
    func createManagedBikeRentalStation(
        name: String,
        stationId: String,
        lat: Double,
        lon: Double,
        spacesAvailable: Int64,
        bikesAvailable: Int64,
        allowDropoff: Bool,
        favorite: Bool,
        state: Bool,
        fetched: Date
    ) -> BikeRentalStation {
        let managedBikeRentalStation = BikeRentalStation(context: moc)
        managedBikeRentalStation.stationId = stationId
        managedBikeRentalStation.name = name
        managedBikeRentalStation.lat = lat
        managedBikeRentalStation.lon = lon
        managedBikeRentalStation.bikesAvailable = bikesAvailable
        managedBikeRentalStation.spacesAvailable = spacesAvailable
        managedBikeRentalStation.allowDropoff = allowDropoff
        managedBikeRentalStation.favorite = favorite
        managedBikeRentalStation.fetched = fetched
        managedBikeRentalStation.state = state
        return managedBikeRentalStation
    }

    // swiftlint:disable:next function_parameter_count
    func createUnmanagedBikeRentalStation(
        name: String,
        stationId: String,
        lat: Double,
        lon: Double,
        spacesAvailable: Int64,
        bikesAvailable: Int64,
        allowDropoff: Bool,
        favorite: Bool,
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

    func toManagedStation(unmanaged: RentalStation) -> BikeRentalStation? {
        if unmanaged is UnmanagedBikeRentalStation {
            let managedBikeRentalStation = createManagedBikeRentalStation(
                name: unmanaged.name,
                stationId: unmanaged.id,
                lat: unmanaged.lat,
                lon: unmanaged.lon,
                spacesAvailable: unmanaged.spacesAvailable,
                bikesAvailable: unmanaged.bikesAvailable,
                allowDropoff: unmanaged.allowDropoff,
                favorite: true,
                state: unmanaged.state,
                fetched: unmanaged.fetched
            )
            saveMoc()
            return managedBikeRentalStation
        }
        return nil
    }

    func toUnmanagedStation(managed: RentalStation) -> UnmanagedBikeRentalStation? {
        if managed is BikeRentalStation {
            let unmanagedBikeRentalStation = createUnmanagedBikeRentalStation(
                name: managed.name,
                stationId: managed.stationId,
                lat: managed.lat,
                lon: managed.lon,
                spacesAvailable: managed.spacesAvailable,
                bikesAvailable: managed.bikesAvailable,
                allowDropoff: managed.allowDropoff,
                favorite: false,
                state: managed.state,
                fetched: managed.fetched
            )
            // swiftlint:disable force_cast
            deleteBikeRentalStation(managed as! BikeRentalStation)
            // swiftlint:enable force_cast
            stationsNearby.value.append(unmanagedBikeRentalStation)
            return unmanagedBikeRentalStation
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

extension BikeRentalStationStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedBikeRentalStations = controller.fetchedObjects as? [BikeRentalStation] else { return }
        self.stationsFavorite.value = fetchedBikeRentalStations
    }
}
