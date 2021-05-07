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

    private init() {}

}

// MARK: - Saving and loading of data
extension BikeRentalStationStore {

    /// Directory URL for where to save the data files. File is saved in the HelsinkiBikeBuddy -group
    /// folder enabling the widget and intents extension to access the Bike Rental Stations.
    static var documentsFolder: URL? {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.HelsinkiBikeBuddy"
        ) else {
            Log.e("Failed to unwrap appgroup directory URL")
            return nil
        }
        return url
    }

    /// URL BikeRentalStations .data file
    static var fileUrl: URL? {
        #if DEBUG
        if Helper.isRunningTests() {
            return URL(string: "bikerentalstations_tests.data")
        }
        #endif
        return URL(string: "bikerentalstations.data")
    }

    /// Loads contents of persistent store to *bikeRentalStations* and *bikeRentalStationIds*
    func loadData() throws {
        guard let directory = Self.documentsFolder,
              let fileExtension = Self.fileUrl else {
            throw BikeRentalStationStoreError.fileAccessFailed
        }

        let fullFilePath = directory.appendingPathComponent(fileExtension.absoluteString)

        guard let data = try? Data(contentsOf: fullFilePath) else {
            Log.e("Failed to read file from: \(fullFilePath)")
            return
        }

        guard let bikeRentalStationsFromData =
                try? JSONDecoder().decode([BikeRentalStation].self, from: data) else {
            Log.e("Failed to decode saved Bike Rental Stations!")
            throw BikeRentalStationStoreError.fileLoadFailed
        }

        self.insertStations(bikeRentalStationsFromData)
    }

    /// Saves the favourite Bike Rental Stations persistently.
    func saveData() throws {

        guard let directory = Self.documentsFolder,
              let fileExtension = Self.fileUrl else {
            throw BikeRentalStationStoreError.fileAccessFailed
        }

        let fullFilePath = directory.appendingPathComponent(fileExtension.absoluteString)

        let bikeRentalStationsToSave = bikeRentalStations.values.filter { $0.favourite }

        guard let data = try? JSONEncoder().encode(bikeRentalStationsToSave) else {
            Log.e("Failed to encode data")
            throw BikeRentalStationStoreError.fileWriteFailed
        }

        do {
            try data.write(to: fullFilePath)
        } catch {
            Log.e("Failed to write to file: \(fullFilePath)")
            throw BikeRentalStationStoreError.fileWriteFailed
        }
    }

}

// MARK: - Interaction with the store
extension BikeRentalStationStore {

    /// Insert Bike Rental Stations to the store
    /// If station is already present in the store its values are updated
    /// - Parameter stationsToAdd: Bike Rental Station objects to be added
    /// - Returns: A set of stationIds that were updated / inserted
    func insertStations(_ stationsToAdd: [BikeRentalStation]) {
        for rentalStationToAdd in stationsToAdd {
            // Station already in store, update values
            if let existingStation = bikeRentalStations[rentalStationToAdd.stationId] {
                updateStationValues(existingStation, to: rentalStationToAdd)
                continue
            }
            // Inserting new station
            bikeRentalStations[rentalStationToAdd.stationId] = rentalStationToAdd
        }

        bikeRentalStationIds.value = [String](bikeRentalStations.keys)
    }

    /// Update Bike Rental Station with new values
    /// - Parameter stationToUpdate: Bike Rental Station object to update
    /// - Parameter values: Bike Rental Station object with new data
    private func updateStationValues(_ stationToUpdate: BikeRentalStation, to values: BikeRentalStation) {
        stationToUpdate.name = values.name
        stationToUpdate.lat = values.lat
        stationToUpdate.lon = values.lon
        stationToUpdate.allowDropoff = values.allowDropoff
        stationToUpdate.state = values.state
        stationToUpdate.bikes = values.bikes
        stationToUpdate.spaces = values.spaces
        stationToUpdate.fetched = Date()
    }

    /// Removes all Bike Rental Stations from store
    func clearStore() {
        bikeRentalStations = [:]
        bikeRentalStationIds.value = []
    }
}

// MARK: - Enums
extension BikeRentalStationStore {

    enum BikeRentalStationStoreError: Error {
        case fileAccessFailed
        case fileWriteFailed
        case fileLoadFailed
    }
}
