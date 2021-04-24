//
//  BikeRentalStationWidgetEntry.swift
//  BikeBuddyWidgetExtension
//
//  Created by Juan Covarrubias on 16.4.2021.
//

import Foundation
import WidgetKit

struct BikeRentalStationWidgetEntry: TimelineEntry {

    let date: Date
    let configuration: ConfigurationIntent
    let bikeRentalStation: BikeRentalStation?
    let lastRefreshOccasion: LastRefreshOccasion
    let widgetDisplayType: WidgetDisplayType

}
// MARK: - Enums
extension BikeRentalStationWidgetEntry {

    public enum LastRefreshOccasion {
        case now
        case recently
        case prolonged
    }

    public enum WidgetDisplayType {
        case preview
        case operational
    }

}

extension Timeline {
    static func createBikeRentalStationTimeline(entry: EntryType) -> Timeline {
        let nextDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextDate))
        return timeline
    }
}
