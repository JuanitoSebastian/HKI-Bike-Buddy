//
//  RentalStationStore.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.4.2021.
//

import Foundation
import Combine
import CoreLocation

/// A class for persistently storing Bike Rental Station objects
/// # Usage
/// Class is accessed via a singleton instance
/// ```
/// BikeRentalStationStore.shared
/// ```
/// # Structure
/// BikeRentalStation objects are kept in dictionary *bikeRentalStations* where stationId strings work as keys.
/// Users of the class can subscribe to the CurrentValueSubject *bikeRentalStationIds* which contains
/// an array of stationIds of stations that have been fetched from the API. This array of stationIds is always
/// sorted from nearest to furthers stationId from the user
/// # Persistent storage
/// Bike rental stations are persistently stored as JSON in a .data file. This file can be accessed by the main app,
/// intents extension and widget extension.
class BikeRentalStationStore {

    static let shared = BikeRentalStationStore()

    private(set) var bikeRentalStations: [String: BikeRentalStation] = [:]
    public let bikeRentalStationIds = CurrentValueSubject<[String], Never>([])

    private init() {
        loadData()
    }

}

// MARK: - Saving and loading of data
extension BikeRentalStationStore {

    static var documentsFolder: URL {
        guard let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.HelsinkiBikeBuddy"
        ) else {
            fatalError("Directory not found")
        }
        return url
    }

    static var fileUrl: URL {
        return documentsFolder.appendingPathComponent("bikerentalstations.data")
    }

    /// Loads contents of persistent store to *bikeRentalStations* and *bikeRentalStationIds*
    private func loadData() {
        DispatchQueue.main.async {
            guard let data = try? Data(contentsOf: Self.fileUrl) else {
                return
            }

            guard let bikeRentalStationsFromData =
                    try? JSONDecoder().decode([BikeRentalStation].self, from: data) else {
                Log.e("Failed to decode saved Bike Rental Stations!")
                return
            }

            self.addBikeRentalStations(bikeRentalStationsFromData)

        }
    }

    /// Saves the favourite Bike Rental Stations persistently.
    /// Data is written in background thread
    func saveData() {
        DispatchQueue.global(qos: .background).async { [weak self] in

            guard let bikeRentalStationsToSave = self?.bikeRentalStations.values.filter({ $0.favourite }) else {
                Log.e("Self out of scope")
                return
            }

            guard let data = try? JSONEncoder().encode(bikeRentalStationsToSave) else {
                Log.e("Failed to encode data")
                return
            }

            do {
                let outfile = Self.fileUrl
                try data.write(to: outfile)
            } catch {
                Log.e("Failed to write to file")
            }
        }
    }

}

// MARK: - Interaction with the store
extension BikeRentalStationStore {

    var favouritesEmpty: Bool {
        bikeRentalStations.values.contains { !$0.favourite }
    }

    func addBikeRentalStations(_ stationsToAdd: [BikeRentalStation]) {

        var stationIds: [String] = bikeRentalStationIds.value
        for rentalStationToAdd in stationsToAdd {
            bikeRentalStations[rentalStationToAdd.stationId] = rentalStationToAdd
            stationIds.append(rentalStationToAdd.stationId)
        }

        bikeRentalStationIds.value = stationIds
            .compactMap { bikeRentalStations[$0] }
            .sorted()
            .map { $0.stationId }
    }

    func isStationFavourite(stationId: String) -> Bool {
        guard let bikeRentalStation = bikeRentalStations[stationId] else { return false }
        return bikeRentalStation.favourite
    }

}
