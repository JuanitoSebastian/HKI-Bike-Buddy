//
//  BikeRentalStationWidgetEntry.swift
//  BikeBuddyWidgetExtension
//
//  Created by Juan Covarrubias on 16.4.2021.
//

import Foundation
import WidgetKit

/// Struct containing information to be displayed in bike rental station widgets
struct BikeRentalStationWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let bikeRentalStation: BikeRentalStation?
    let widgetDisplayType: WidgetDisplayType

}

// MARK: - Enums
extension BikeRentalStationWidgetEntry {
    public enum WidgetDisplayType {
        case preview
        case operational
    }

}
