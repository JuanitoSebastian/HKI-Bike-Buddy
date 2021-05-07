//
//  BikeBuddyWidgetProvider.swift
//  BikeBuddyWidgetExtension
//
//  Created by Juan Covarrubias on 19.4.2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {

    /// This function is called when the actual widget is loading and the system needs to display a
    /// placeholder item when the actual content of the widget is loading
    func placeholder(in context: Context) -> BikeRentalStationWidgetEntry {

        let placeholderStation = BikeRentalStation.placeholderStations[
            Int.random(in: 0..<BikeRentalStation.placeholderStations.count)
        ]

        return BikeRentalStationWidgetEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            bikeRentalStation: placeholderStation,
            widgetDisplayType: .preview
        )
    }

    /// Called when the system needs an example instance of the widget
    /// A snapshot is displayed when the user is previews widgets
    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (BikeRentalStationWidgetEntry) -> Void
    ) {

        let placeholderStation = BikeRentalStation.placeholderStations[
            Int.random(in: 0..<BikeRentalStation.placeholderStations.count)
        ]

        let entry = BikeRentalStationWidgetEntry(
            date: Date(),
            configuration: configuration,
            bikeRentalStation: placeholderStation,
            widgetDisplayType: .preview
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<BikeRentalStationWidgetEntry>) -> Void
    ) {

        let idToFetch = configuration.bikeRentalStation?.identifier ??
            BikeRentalStation.placeholderStations[
                Int.random(in: 0..<BikeRentalStation.placeholderStations.count)
            ].stationId

        BikeRentalStationAPI  .shared.fetchBikeRentalStation(
            stationId: idToFetch
        ) { (_ bikeRentalStation: BikeRentalStation?, _ error: Error?) in

            guard error == nil else {
                return
            }

            guard let bikeRentalStationUnwrapped = bikeRentalStation else {
                return
            }

            let entry = BikeRentalStationWidgetEntry(
                date: Date(),
                configuration: configuration,
                bikeRentalStation: bikeRentalStationUnwrapped,
                widgetDisplayType: .operational
            )

            let timeline = Timeline(
                entries: [entry],
                policy: .after(Date().addingTimeInterval(900)) // 15 minutes
            )

            completion(timeline)
        }
    }
}
