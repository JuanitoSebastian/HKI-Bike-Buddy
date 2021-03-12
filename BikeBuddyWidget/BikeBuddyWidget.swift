//
//  BikeBuddyWidget.swift
//  BikeBuddyWidget
//
//  Created by Juan Covarrubias on 11.3.2021.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> BikeRentalStationWidgetEntry {
        let placeholderStation = UnmanagedBikeRentalStation(
            stationId: "014",
            name: "Senaatintori",
            allowDropoff: true,
            bikesAvailable: 14,
            favorite: false,
            fetched: Date(),
            lat: -1,
            lon: -1,
            spacesAvailable: 2,
            state: true
        )
        return BikeRentalStationWidgetEntry(date: Date(), configuration: ConfigurationIntent(), bikeRentalStation: placeholderStation)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (BikeRentalStationWidgetEntry) -> Void) {
        let placeholderStation = UnmanagedBikeRentalStation(
            stationId: "014",
            name: "Senaatintori",
            allowDropoff: true,
            bikesAvailable: 14,
            favorite: false,
            fetched: Date(),
            lat: -1,
            lon: -1,
            spacesAvailable: 2,
            state: true
        )
        let entry = BikeRentalStationWidgetEntry(date: Date(), configuration: configuration, bikeRentalStation: placeholderStation)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [BikeRentalStationWidgetEntry] = []
        print("timeline")
        print(configuration)
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let nextDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!

        if let idToFetch = configuration.bikeRentalStation?.identifier {
            let bikeRentalStationFromMoc = BikeRentalStationStorage.shared.bikeRentalStationFromCoreData(stationId: idToFetch)
            let entry = BikeRentalStationWidgetEntry(date: Date(), configuration: configuration, bikeRentalStation: bikeRentalStationFromMoc)
            let timeline = Timeline(entries: [entry], policy: .after(nextDate))
            completion(timeline)
        } else {
            let entry = BikeRentalStationWidgetEntry(date: Date(), configuration: configuration, bikeRentalStation: nil)
            let timeline = Timeline(entries: [entry], policy: .after(nextDate))
            completion(timeline)
        }

    }
}

struct BikeRentalStationWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let bikeRentalStation: RentalStation?
}

struct BikeBuddyWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        content
    }

    var content: AnyView {
        if entry.bikeRentalStation == nil {
            return AnyView(
                Text("Choose a station")
            )
        }
        return AnyView(
            ZStack {
                VStack {
                    HStack {
                        Text(entry.bikeRentalStation!.name)
                            .font(.custom("Helvetica Neue Condensed Bold", size: 35))
                        Spacer()
                    }
                    Spacer()
                    CapacityBar(bikesAvailable: Int(entry.bikeRentalStation!.bikesAvailable), spacesAvailable: Int(entry.bikeRentalStation!.spacesAvailable))
                    HStack {
                        Text("\(entry.bikeRentalStation!.bikesAvailable) bikes")
                            .font(.headline)
                            .foregroundColor(Color("TextMain"))
                        Spacer()
                        Text("\(entry.bikeRentalStation!.spacesAvailable) spaces")
                            .font(.headline)
                            .foregroundColor(Color("TextMain"))
                    }
                }
                .padding([.leading, .trailing], 15)
                .padding([.bottom, .top], 10)
            }
        )
    }
}

@main
struct BikeBuddyWidget: Widget {
    let kind: String = "BikeBuddyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            BikeBuddyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

/*
struct BikeBuddyWidget_Previews: PreviewProvider {
    static var previews: some View {
        BikeBuddyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
*/
