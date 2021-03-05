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

enum ApiState {
    case allGood
    case setup
    case error
}

// TODO: Handle errors in networking
// TODO: UserSettings -> Nearby length

class BikeRentalService: ObservableObject, ReachabilityObserverDelegate {

    private let bikeRentalStationStore = BikeRentalStationStorage.shared
    private let userLocationManager = UserLocationManager.shared
    private var timer: Timer?
    @Published var apiState: ApiState

    // Singleton
    static let shared = BikeRentalService()

    private init() {
        self.timer = nil
        self.apiState = .setup
        try? addReachabilityObserver()
    }

    deinit {
        removeReachabilityObserver()
    }

    func reachabilityChanged(_ isReachable: Bool) {
        if isReachable {
            setState(.allGood)
            return
        }
        setState(.error)
    }

    func setTimer() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 30,
            target: self,
            selector: #selector(updateAll),
            userInfo: nil,
            repeats: true
        )
    }

    @objc
    func updateAll() {
        updateFavorites()
        fetchNearbyStations()
    }

    func updateFavorites() {
        for var bikeRentalStation in bikeRentalStationStore.stationsFavorite.value {
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
        if apiState == .error { return }
        Network.shared.apollo.fetch(
            query: FetchNearByBikeRentalStationsQuery(
                lat: userLocationManager.userLocation.coordinate.latitude,
                lon: userLocationManager.userLocation.coordinate.longitude,
                maxDistance: 1000
            )
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let edgesUnwrapped = graphQLResult.data?.nearest?.edges else { return }
                // Iterating thru the fetched stations
                var nearbyStationFetched: [RentalStation] = []
                for edge in edgesUnwrapped {
                    guard let stationUnwrapped = self.unwrapGraphQLStationObject(edge?.node?.place?.asBikeRentalStation) else {
                        return
                    }
                    if let bikeRentalStationCoreData = self.bikeRentalStationStore.bikeRentalStationFromCoreData(
                        stationId: stationUnwrapped.stationId!
                    ) {
                        nearbyStationFetched.append(bikeRentalStationCoreData)
                    } else {
                        let bikeRentalStationUnmanaged = UnmanagedBikeRentalStation(
                            stationId: stationUnwrapped.stationId!,
                            name: stationUnwrapped.name,
                            allowDropoff: stationUnwrapped.allowDropoff!,
                            bikesAvailable: Int64.random(in: 0...15),
                            favorite: false,
                            fetched: Date(),
                            lat: stationUnwrapped.lat!,
                            lon: stationUnwrapped.lon!,
                            spacesAvailable: Int64.random(in: 0...15),
                            state: self.parseStateString(stationUnwrapped.state!)
                        )
                        nearbyStationFetched.append(bikeRentalStationUnmanaged)
                    }
                    self.bikeRentalStationStore.stationsNearby.value = nearbyStationFetched
                }
            case .failure(let error):
                Helper.log("API Fecth failed: \(error)")
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

    private func parseStateString(_ state: String) -> Bool {
        if state.contains("off") { return false }
        return true
    }

    private func setState(_ newApiState: ApiState) {
        if apiState != newApiState {
            apiState = newApiState
        }
    }
}
