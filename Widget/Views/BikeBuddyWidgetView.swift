//
//  BikeBuddyWidgetView.swift
//  BikeBuddyWidgetExtension
//
//  Created by Juan Covarrubias on 19.4.2021.
//

import WidgetKit
import SwiftUI
import Intents

/// This view wraps the WidgetStationCard view.
/// If the station was not fetched succesfully an error message is displayed
struct BikeBuddyWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {

        guard let bikeRentalStation = entry.bikeRentalStation else {
            return AnyView(
                Text("Unable to fetch station")
                    .font(.caption)
            )
        }

        return AnyView(
            WidgetStationCard(
                bikeRentalStation: bikeRentalStation,
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
                widgetDisplayType: .operational
            )
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
