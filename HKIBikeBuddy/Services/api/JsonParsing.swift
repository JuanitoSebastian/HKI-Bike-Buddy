//
//  JsonParsing.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 22.4.2021.
//

import Foundation

/// These structs are used for the decoding of API responses

// MARK: - NearbyStations
struct WelcomeNearby: Codable {
    let data: DataClassNearby
}

struct DataClassNearby: Codable {
    let nearest: Nearest
}

struct Nearest: Codable {
    let edges: [Edge]
}

struct Edge: Codable {
    let node: Node
}

struct Node: Codable {
    let place: BikeRentalStation
    let distance: Int
}

// MARK: - Fetch single station
struct WelcomeSingleStation: Codable {
    let data: DataClassSingle
}

struct DataClassSingle: Codable {
    let bikeRentalStation: BikeRentalStation
}

// MARK: - Fetch multiple stations
struct WelcomeMultipleStations: Codable {
    let data: DataMultipleStations
}

struct DataMultipleStations: Codable {
    let bikeRentalStations: [BikeRentalStation]
}
