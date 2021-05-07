//
//  IntentHandler.swift
//  BikeBuddyIntention
//
//  Created by Juan Covarrubias on 11.3.2021.
//

import Intents

/// This class is used for the customizable widget implementation
/// The IntentHandler provides list of favourite stations from which the user chooses
/// the station for the widget.
class IntentHandler: INExtension, ConfigurationIntentHandling {

    func provideBikeRentalStationOptionsCollection(
        for intent: ConfigurationIntent,
        with completion: @escaping (INObjectCollection<WidgetStation>?, Error?) -> Void
    ) {

        guard let directory = BikeRentalStationStore.documentsFolder,
              let fileExtension = BikeRentalStationStore.fileUrl else {
            completion(nil, IntentHandlerError.failedToLoadStations)
            return
        }

        let fullFilePath = directory.appendingPathComponent(fileExtension.absoluteString)

        guard let data = try? Data(contentsOf: fullFilePath) else {
            completion(nil, IntentHandlerError.failedToLoadStations)
            return
        }

        guard let bikeRentalStationsFromData =
                try? JSONDecoder().decode([BikeRentalStation].self, from: data) else {
            Log.e("Failed to decode saved Bike Rental Stations!")
            completion(nil, IntentHandlerError.failedToLoadStations)
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

    enum IntentHandlerError: Error {
        case failedToLoadStations
    }

}
