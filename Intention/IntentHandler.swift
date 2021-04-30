//
//  IntentHandler.swift
//  BikeBuddyIntention
//
//  Created by Juan Covarrubias on 11.3.2021.
//

import Intents
import CoreData

class IntentHandler: INExtension, ConfigurationIntentHandling {
    func provideBikeRentalStationOptionsCollection(
        for intent: ConfigurationIntent,
        with completion: @escaping (INObjectCollection<WidgetStation>?, Error?) -> Void
    ) {

        guard let directory = BikeRentalStationStore.documentsFolder,
              let fileExtension = BikeRentalStationStore.fileUrl else {
            return
        }

        let fullFilePath = directory.appendingPathComponent(fileExtension.absoluteString)

        guard let data = try? Data(contentsOf: fullFilePath) else {
            return
        }

        guard let bikeRentalStationsFromData =
                try? JSONDecoder().decode([BikeRentalStation].self, from: data) else {
            Log.e("Failed to decode saved Bike Rental Stations!")
            return
        }

        let stations: [WidgetStation] =
            bikeRentalStationsFromData
                .filter { $0.favourite }
                .map { bikeRentalStation in
                    let widgetStation = WidgetStation(
                        identifier: bikeRentalStation.stationId,
                        display: bikeRentalStation.name
                    )
                    return widgetStation
                }

        let collection = INObjectCollection(items: stations)

        completion(collection, nil)

    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        return self
    }

}
