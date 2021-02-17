//
//  Helper.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import CoreData

class Helper {

    static func log(_ printMe: Any) {
        #if DEBUG
        print(printMe)
        #endif
    }

    static func saveViewContext(_ viewContext: NSManagedObjectContext) {
        if !viewContext.hasChanges { return }
        do {
            try viewContext.save()
        } catch {
            Helper.log("Failed to save ViewContext")
            Helper.log("Because of error: \(error.localizedDescription)")
        }
    }

    static func removeBikeRentalStation(bikeRentalStation: BikeRentalStation, viewContext: NSManagedObjectContext) {
        viewContext.delete(bikeRentalStation)
    }
}