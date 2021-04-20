//
//  BikeBuddyWidget.swift
//  BikeBuddyWidget
//
//  Created by Juan Covarrubias on 11.3.2021.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct BikeBuddyWidget: Widget {
    let kind: String = "BikeBuddyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            BikeBuddyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Favourite Bike Rental Station")
        .description("Displays the current state of a favourite station 🚴")
        .supportedFamilies([.systemMedium])
    }
}
