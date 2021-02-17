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

    var stationsManaged = CurrentValueSubject<[RentalStation], Never>([])
    var stationsUnmanaged = CurrentValueSubject<[RentalStation], Never>([])
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
            self.stationsManaged.value = bikeRentalStationsArray
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
        state: Bool
    ) {
        let managedBikeRentalStation = BikeRentalStation(context: moc)
        managedBikeRentalStation.stationId = stationId
        managedBikeRentalStation.name = name
        managedBikeRentalStation.lat = lat
        managedBikeRentalStation.lon = lon
        managedBikeRentalStation.bikesAvailable = bikesAvailable
        managedBikeRentalStation.spacesAvailable = spacesAvailable
        managedBikeRentalStation.allowDropoff = allowDropoff
        managedBikeRentalStation.favorite = favorite
        managedBikeRentalStation.fetched = Date()
        managedBikeRentalStation.state = state
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
        state: Bool
    ) {
        let unmanagedBikeRentalStation = UnmanagedBikeRentalStation(
            stationId: stationId,
            name: name,
            allowDropoff: allowDropoff,
            bikesAvailable: bikesAvailable,
            favorite: false,
            fetched: Date(),
            lat: lat,
            lon: lon,
            spacesAvailable: spacesAvailable,
            state: state
        )
        stationsUnmanaged.value.append(unmanagedBikeRentalStation)
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

    func toManagedStation(unmanaged: UnmanagedBikeRentalStation) {
        createManagedBikeRentalStation(
            name: unmanaged.name,
            stationId: unmanaged.id,
            lat: unmanaged.lat,
            lon: unmanaged.lon,
            spacesAvailable: unmanaged.spacesAvailable,
            bikesAvailable: unmanaged.bikesAvailable,
            allowDropoff: unmanaged.allowDropoff,
            favorite: unmanaged.favorite,
            state: unmanaged.state
        )
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
        self.stationsManaged.value = fetchedBikeRentalStations
    }
}
