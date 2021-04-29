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
class RoutingAPI: ObservableObject {

    static let shared = RoutingAPI()

    private init() {}

    /// Fetch multiple Bike Rental Stations around a given coordinate location
    /// - Parameter lat: Latitude of location
    /// - Parameter lon: Longitude of location
    /// - Parameter radius: Radius around coordinate location in meters
    /// - Parameter completion: A completion handler that is either passed an array of BikeRentalStations (success) or
    /// an Error (failure)
    func fetchNearbyBikeRentalStations(
        lat: Double,
        lon: Double,
        radius: Int,
        completion: @escaping (_ fetchedBikeRentalStations: [BikeRentalStation]?, _ error: Error?) -> Void
    ) {

        let bikeRentalStationsAPI = ApiRouter<WelcomeNearby>()

        let router = DigitransitRoutable.fetchNearbyBikeRentalStations(
            lat: lat,
            lon: lon,
            nearbyRadius: radius
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

    /// Fetches multiple Bike Rental Stations by their stationId
    /// - Parameter stationIds: The stationIds to fetch
    /// - Parameter completion: A completion handler that is either passed an array of BikeRentalStations (success) or
    /// an Error (failure)
    func fetchBikeRentalStations(
        stationIds: [String],
        completion: @escaping (_ fetchedBikeRentalStations: [BikeRentalStation]?, _ error: Error?) -> Void
    ) {
        let bikeRentalStationAPI = ApiRouter<WelcomeMultipleStations>()

        let router = DigitransitRoutable.fetchBikeRentalStations(stationIds: stationIds)

        bikeRentalStationAPI.requestData(router: router) { (_ responseData: WelcomeMultipleStations?, _ error: Error?) in
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let responseData = responseData else {
                completion(nil, nil)
                return
            }

            let bikeRentalStationsFromAPI = responseData.data.bikeRentalStations

            completion(bikeRentalStationsFromAPI, nil)
        }
    }

    /// Fetch a single Bike Rental Station by its stationId
    /// - Parameter stationId: The stationId to fetch
    /// - Parameter completion: A completion handler that is either passed a BikeRentalStation (success) or
    /// an Error (failure)
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
