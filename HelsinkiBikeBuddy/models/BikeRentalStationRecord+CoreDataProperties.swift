//
//  BikeRentalStationRecord+CoreDataProperties.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.4.2021.
//
//

import Foundation
import CoreData

extension BikeRentalStationRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BikeRentalStationRecord> {
        return NSFetchRequest<BikeRentalStationRecord>(entityName: "BikeRentalStationRecord")
    }

    @NSManaged public var stationId: String
    @NSManaged public var name: String

}

extension BikeRentalStationRecord: Identifiable {

    public var id: String {
        stationId
    }
}
