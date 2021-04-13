//
//  RentalStationStore.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.4.2021.
//

import Foundation
import Combine
import CoreLocation
// MARK: - Initiation of class

class RentalStationStore {
    /// Singleton instance of class
    static let shared = RentalStationStore()

    private static var documentsFolder: URL {
        guard let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.HelsinkiBikeBuddy"
        ) else {
            fatalError("Directory not found")
        }
        return url
    }

    private static var fileUrl: URL {
        return documentsFolder.appendingPathComponent("bikerentalstations.data")
    }

    private(set) var bikeRentalStations: [String: BikeRentalStation] = [:]
    public let bikeRentalStationIds = CurrentValueSubject<[String], Never>([])

    private init() {
        loadData()
    }

    private func loadData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileUrl) else {
                return
            }

            guard let bikeRentalStationsFromData =
                    try? JSONDecoder().decode([BikeRentalStation].self, from: data) else {
                Log.e("Failed to decode saved Bike Rental Stations!")
                return
            }

            DispatchQueue.main.async {
                self?.addBikeRentalStations(bikeRentalStationsFromData)
            }
        }
    }

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
extension RentalStationStore {

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
