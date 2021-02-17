//
//  BikeRentalService.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 12.2.2021.
//

import Foundation
import Apollo
import ApolloWebSocket

class Network {
    static let shared = Network()
    let url = "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"
    private(set) lazy var apollo = ApolloClient(url: URL(string: url)!)
}

class BikeRentalService {

    enum ApiError: Error {
        case invalidResponse
        case connectionFailure
    }

    private let bikeRentalStationStore = BikeRentalStationStorage.shared
    private let userLocationManager = UserLocationManager.shared

    // Singleton
    static let shared = BikeRentalService()

    func updateStations() {
        for var bikeRentalStation in bikeRentalStationStore.stationsManaged.value {
            Helper.log("In updateLoop")
            bikeRentalStation.fetched = Date()

            let total = Int64(bikeRentalStation.totalCapacity)

            bikeRentalStation.bikesAvailable = Int64.random(in: 0...total)
            bikeRentalStation.spacesAvailable = total - bikeRentalStation.bikesAvailable

        }
        bikeRentalStationStore.saveMoc()
    }

    func updateStationValues(
        bikeRentalStation: BikeRentalStation,
        resBikeRentalStop: AllBikeRentalStatationsQuery.Data.BikeRentalStation
    ) {
        bikeRentalStation.lat = resBikeRentalStop.lat!
        bikeRentalStation.lon = resBikeRentalStop.lon!
        bikeRentalStation.spacesAvailable = Int64.random(in: 0...15)
        bikeRentalStation.bikesAvailable = Int64.random(in: 0...15)
        bikeRentalStation.allowDropoff = resBikeRentalStop.allowDropoff!
        bikeRentalStation.favorite = false
        bikeRentalStation.state = true
    }

    func fetchNearbyStations() {
        Network.shared.apollo.fetch(
            query: FetchNearByBikeRentalStationsQuery(
                lat: userLocationManager.userLocation.coordinate.latitude,
                lon: userLocationManager.userLocation.coordinate.longitude,
                maxDistance: 500
            )
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let edgesUnwrapped = graphQLResult.data?.nearest?.edges else { return }
                // Iterating thru the fetched stations
                for edge in edgesUnwrapped {
                    guard let stationUnwrapped = self.unwrapGraphQLStationObject(edge?.node?.place?.asBikeRentalStation) else { return }
                    self.bikeRentalStationStore.createUnmanagedBikeRentalStation(
                        name: stationUnwrapped.name,
                        stationId: stationUnwrapped.stationId!,
                        lat: stationUnwrapped.lat!,
                        lon: stationUnwrapped.lon!,
                        spacesAvailable: Int64(stationUnwrapped.spacesAvailable!),
                        bikesAvailable: Int64(stationUnwrapped.bikesAvailable!),
                        allowDropoff: stationUnwrapped.allowDropoff!,
                        favorite: false,
                        state: true
                    )
                }
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }

    private func unwrapGraphQLStationObject(_ wrapped: FetchNearByBikeRentalStationsQuery.Data.Nearest.Edge.Node.Place.AsBikeRentalStation?)
    -> FetchNearByBikeRentalStationsQuery.Data.Nearest.Edge.Node.Place.AsBikeRentalStation? {
        guard let stationUnwrapped = wrapped else { return nil }
        if stationUnwrapped.stationId == nil || stationUnwrapped.lat == nil || stationUnwrapped.lon == nil ||
            stationUnwrapped.spacesAvailable == nil || stationUnwrapped.spacesAvailable == nil ||
            stationUnwrapped.state == nil || stationUnwrapped.allowDropoff == nil {
            return nil
        }
        return stationUnwrapped
    }
}
