//
//  RentalStation.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.2.2021.
//

import Foundation
import CoreLocation

protocol RentalStation {

    var allowDropoff: Bool { get set }
    var bikesAvailable: Int64 { get set }
    var favorite: Bool { get set }
    var fetched: Date { get set }
    var lat: Double { get set }
    var lon: Double { get set }
    var name: String { get set }
    var spacesAvailable: Int64 { get set }
    var stationId: String { get set }
    var state: Bool { get set }

    var location: CLLocation { get }
    var totalCapacity: Int { get }
    var id: String { get }

    func distance(to location: CLLocation) -> CLLocationDistance

}
