//
//  BikeBuddyWidget.swift
//  BikeBuddyWidget
//
//  Created by Juan Covarrubias on 11.3.2021.
//

import WidgetKit
import SwiftUI
import Intents
import CoreLocation

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> BikeRentalStationWidgetEntry {
        let placeholderStation = UnmanagedBikeRentalStation(
            stationId: "014",
            name: "Senaatintori",
            allowDropoff: true,
            bikesAvailable: 14,
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
            let bikeRentalStationFromMoc = BikeRentalStationStore.shared.bikeRentalStationFromCoreData(stationId: idToFetch)
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

    func distanceInMeters() -> String {
        let location = CLLocation(latitude: entry.bikeRentalStation!.lat, longitude: entry.bikeRentalStation!.lon)
        var distanceDouble = Double(location.distance(from: UserLocationService.shared.userLocation)).rounded()
        if distanceDouble >= 1000 {
            distanceDouble /= 1000
            return "\(String(distanceDouble))km"
        }
        return "\(String(distanceDouble))m"
    }

    var body: some View {
        content
    }

    var content: AnyView {
        if entry.bikeRentalStation == nil {
            return AnyView(
                Text("Start by choosing the station!")
            )
        }
        return AnyView(
            ZStack {
                VStack {
                    HStack {
                        Text(entry.bikeRentalStation!.name)
                            .font(.custom("Helvetica Neue Condensed Bold", size: 35))
                            .foregroundColor(Color("TextTitle"))
                        Spacer()
                    }
                    HStack {
                        Text("\(distanceInMeters()) away 🚶")
                            .foregroundColor(Color("TextMain"))
                        Spacer()

                    }
                    VStack {
                        CapacityBar(leftValue: Int(entry.bikeRentalStation!.bikesAvailable), rightValue: Int(entry.bikeRentalStation!.spacesAvailable))
                            .shadow(color: Color("StationCardShadow"), radius: 3, x: 0, y: 3)
                        HStack {
                            Text("\(entry.bikeRentalStation!.bikesAvailable) bikes")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                            Spacer()
                            Text("\(entry.bikeRentalStation!.spacesAvailable) spaces")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                        }
                        .padding([.leading, .trailing, .bottom], 10)
                    }
                    .background(Color("StationInfoBg"))
                    .cornerRadius(10)
                }
                .padding([.leading, .trailing], 15)
            }
            .padding([.bottom], 20)
            .padding([.top], 10)
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
        .configurationDisplayName("Bike Rental Station")
        .description("View the current status of a favorited bike rental station.")
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
