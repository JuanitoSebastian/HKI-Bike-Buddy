//
//  BikeRentalStationService2.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 22.4.2021.
//

import Foundation

/// A class for fetching Bike Rental Stations from the
/// [Digitransit Routing API](https://digitransit.fi/en/developers/apis/1-routing-api/)
/// # Usage
/// Class is accessed via a singleton instance
/// ```
/// RoutingAPI.shared
/// ```
class RoutingAPI {

    static let shared = RoutingAPI()

    private init() {}

    func fetchNearbyBikeRentalStations(
        lat: Double,
        lon: Double,
        nearbyRadius: Int,
        completion: @escaping (_ fetchedBikeRentalStations: [BikeRentalStation]?, _ error: Error?) -> Void
    ) {

        let bikeRentalStationsAPI = ApiRouter<WelcomeNearby>()

        let router = DigitransitRoutable.fetchNearbyBikeRentalStations(
            lat: lat,
            lon: lon,
            nearbyRadius: nearbyRadius
        )

        bikeRentalStationsAPI.requestData(router: router) { (responseData: WelcomeNearby?, error: Error?) in

            guard let responseData = responseData else {
                completion(nil, error)
                return
            }

            let bikeRentalStationFromApi: [BikeRentalStation] = responseData.data.nearest.edges
                .compactMap { $0.node.place }

            completion(bikeRentalStationFromApi, nil)

        }
    }

    func fetchBikeRentalStation(
        stationId: String,
        completion: @escaping (_ fetchedBikeRentalStation: BikeRentalStation?, _ error: Error?) -> Void
    ) {

        let bikeRentalStationAPI = ApiRouter<WelcomeSingleStation>()

        let router = DigitransitRoutable.fetchBikeRentalStation(stationId: stationId)

        bikeRentalStationAPI.requestData(router: router) { (responseData: WelcomeSingleStation?, error: Error?) in

            guard let responseData = responseData else {
                completion(nil, error)
                return
            }

            completion(responseData.data.bikeRentalStation, nil)
        }
    }
}
