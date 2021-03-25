//
//  BikeRentalStation+CoreDataProperties.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 13.2.2021.
//
//

import Foundation
import CoreData

extension ManagedBikeRentalStation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedBikeRentalStation> {
        return NSFetchRequest<ManagedBikeRentalStation>(entityName: "ManagedBikeRentalStation")
    }

    @NSManaged dynamic public var allowDropoff: Bool
    @NSManaged dynamic public var bikesAvailable: Int64
    @NSManaged dynamic public var fetched: Date
    @NSManaged dynamic public var lat: Double
    @NSManaged dynamic public var lon: Double
    @NSManaged dynamic public var name: String
    @NSManaged dynamic public var spacesAvailable: Int64
    @NSManaged dynamic public var stationId: String
    @NSManaged dynamic public var state: Bool

}
