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

    // Singleton
    static let shared = BikeRentalService()

    func updateStations() {
        for bikeRentalStation in bikeRentalStationStore.bikeRentalStations.value.values {
            Helper.log("In updateLoop")
            bikeRentalStation.fetched = Date()

            let total = Int64(bikeRentalStation.totalCapacity)

            bikeRentalStation.bikesAvailable = Int64.random(in: 0...total)
            bikeRentalStation.spacesAvailable = total - bikeRentalStation.bikesAvailable

        }
        bikeRentalStationStore.saveMoc()
    }

    func fetchBikeRentalStation(stationId: String) {
        Helper.log("Fetching from API: \(stationId)")
        Network.shared.apollo.fetch(query: FetchBikeRentalStationByStationIdQuery(stationId: stationId)) { res in
            switch res {
            case .success(let graphQlResult):
                Helper.log("Fetch success")
                if graphQlResult.data!.bikeRentalStation != nil {
                    let resBikeRentalStop = graphQlResult.data!.bikeRentalStation
                    self.bikeRentalStationStore.createBikeRentalStation(
                        name: resBikeRentalStop!.name,
                        stationId: resBikeRentalStop!.stationId!,
                        lat: resBikeRentalStop!.lat!,
                        lon: resBikeRentalStop!.lon!,
                        spacesAvailable: Int.random(in: 0...15),
                        bikesAvailable: Int.random(in: 0...15),
                        allowDropoff: resBikeRentalStop!.allowDropoff!,
                        favorite: true,
                        state: true
                    )
                }
            case .failure(let error):
                Helper.log("Failed to fetch station info from API: \(error)")
            }
        }
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

    func createBikeRentalStation(resBikeRentalStop: AllBikeRentalStatationsQuery.Data.BikeRentalStation) {
        self.bikeRentalStationStore.createBikeRentalStation(
            name: resBikeRentalStop.name,
            stationId: resBikeRentalStop.stationId!,
            lat: resBikeRentalStop.lat!,
            lon: resBikeRentalStop.lon!,
            spacesAvailable: Int.random(in: 0...15),
            bikesAvailable: Int.random(in: 0...15),
            allowDropoff: resBikeRentalStop.allowDropoff!,
            favorite: false,
            state: true
        )
    }

    func fetchAll() {
        Helper.log("Fetching all stations")
        Network.shared.apollo.fetch(query: AllBikeRentalStatationsQuery()) { res in
            switch res {

            case .success(let graphQlResults):
                guard let bikeRentalStations = graphQlResults.data!.bikeRentalStations else { return }
                for stationOptional in bikeRentalStations {
                    Helper.log("Loop!")
                    guard let stationUnwrapped = stationOptional else { continue }

                    if let bikeRentalObj = self.bikeRentalStationStore.bikeRentalStationFromCoreData(
                        stationId: stationUnwrapped.stationId!
                    ) { // Station already cached
                        self.updateStationValues(
                            bikeRentalStation: bikeRentalObj,
                            resBikeRentalStop: stationUnwrapped
                        )
                        continue
                    }
                    // Creation of new station
                    self.createBikeRentalStation(resBikeRentalStop: stationUnwrapped)

                }
                self.bikeRentalStationStore.saveMoc()
            case .failure(let error):
                Helper.log(error)
            }
        }
    }

}
