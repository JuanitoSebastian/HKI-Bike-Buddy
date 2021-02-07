//
//  BikeRentalStation+CoreDataProperties.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//
//

import Foundation
import CoreData

extension BikeRentalStation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BikeRentalStation> {
        return NSFetchRequest<BikeRentalStation>(entityName: "BikeRentalStation")
    }

    @NSManaged public var allowDropoff: Bool
    @NSManaged public var bikesAvailable: Int64
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var name: String
    @NSManaged public var spacesAvailable: Int64
    @NSManaged public var stationId: String

}

extension BikeRentalStation: Identifiable {
    public var id: String {
        return stationId
    }
}
