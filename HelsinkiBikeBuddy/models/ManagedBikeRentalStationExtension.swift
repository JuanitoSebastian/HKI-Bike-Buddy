//
//  BikeRentalStationExtension.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 8.2.2021.
//

import Foundation

// MARK: - Identifiable
extension ManagedBikeRentalStation: Identifiable {
    public var id: String {
        stationId
    }
}

// MARK: - RentalRentalStation
extension ManagedBikeRentalStation: RentalStation {
    var favourite: Bool {
        true
    }
}
