//
//  BikeRentalStationExtension.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 8.2.2021.
//

import Foundation

enum BikeRentalStationValidation: Error {
    case invalidStationId
    case invalidName
    case invalidCoordinates
    case invalidAmount
}

extension BikeRentalStation: Identifiable {

    public var id: String {
        stationId
    }

    var totalCapacity: Int {
        Int(spacesAvailable + bikesAvailable)
    }

    static func validateBikeRentalStation(_ bikeRentalStation: BikeRentalStation) throws {

        if bikeRentalStation.stationId.count > 4 || bikeRentalStation.stationId.count < 3 {
            throw BikeRentalStationValidation.invalidStationId
        }

        if bikeRentalStation.name.count < 3 || bikeRentalStation.name.count > 50 {
            throw BikeRentalStationValidation.invalidName
        }

        if bikeRentalStation.lat > 90 || bikeRentalStation.lat < -90 {
            throw BikeRentalStationValidation.invalidCoordinates
        }

        if bikeRentalStation.lon < -180 || bikeRentalStation.lon > 180 {
            throw BikeRentalStationValidation.invalidCoordinates
        }

        if bikeRentalStation.bikesAvailable < 0 || bikeRentalStation.spacesAvailable < 0 {
            throw BikeRentalStationValidation.invalidAmount
        }

    }

    static func validateStationId(_ stationId: String) throws {
        let regex = "^[0-9]{3,4}$"
        if stationId.range(of: regex, options: .regularExpression) == nil {
            throw BikeRentalStationValidation.invalidStationId
        }

    }

    static func validateName(_ name: String) throws {
        if name.count < 3 || name.count > 50 {
            throw BikeRentalStationValidation.invalidName
        }
    }

    static func validateCoordinates(lat: Double, lon: Double) throws {
        if lat > 90 || lat < -90 {
            throw BikeRentalStationValidation.invalidCoordinates
        }

        if lon < -180 || lon > 180 {
            throw BikeRentalStationValidation.invalidCoordinates
        }

    }

    static func validateAmount(_ amount: Int64) throws {
        if amount < 0 {
            throw BikeRentalStationValidation.invalidAmount
        }
    }
}
