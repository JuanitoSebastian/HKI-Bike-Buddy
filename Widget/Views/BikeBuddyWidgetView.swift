//
//  BikeBuddyWidgetView.swift
//  BikeBuddyWidgetExtension
//
//  Created by Juan Covarrubias on 19.4.2021.
//

import WidgetKit
import SwiftUI
import Intents

struct BikeBuddyWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {

        guard let bikeRentalStation = entry.bikeRentalStation else {
            return AnyView(
                Text("An error has ocurred 🥺")
                    .font(.caption)
            )
        }

        return AnyView(
            WidgetStationCard(
                bikeRentalStation: bikeRentalStation,
                lastRefreshOccasion: entry.lastRefreshOccasion,
                widgetDisplayType: entry.widgetDisplayType
            )
        )
    }
}

#if DEBUG
struct BikeBuddyWidget_Previews: PreviewProvider {
    static var previews: some View {
        BikeBuddyWidgetEntryView(
            entry: BikeRentalStationWidgetEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                bikeRentalStation: BikeRentalStation.placeholderStations[1],
                lastRefreshOccasion: .prolonged,
                widgetDisplayType: .operational
            )
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
