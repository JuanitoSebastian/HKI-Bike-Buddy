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
    case loading
}

// TODO: Handle errors in networking
// TODO: Handle upddating of saved stations

class BikeRentalStationAPI: ObservableObject {

    @Published var apiState: ApiState
    var lastFetchAccurate: Bool?
    var favouriteStationsAlreadyUpdated: Set<String>

    // Singleton instance
    static let shared = BikeRentalStationAPI()

    private init() {
        self.apiState = .setup
        self.favouriteStationsAlreadyUpdated = []
        try? addReachabilityObserver()
    }

    deinit {
        removeReachabilityObserver()
    }

    /// Updates the list of nearby stations in BikeRentalStationStore with an up-to-date version from API and
    /// updates favourite stations with up-to-date data from API
    @objc
    func updateStoreWithAPI() {
        Helper.log("Service: Performing updateAll()")
        favouriteStationsAlreadyUpdated.removeAll()
        setState(.loading)
        fetchNearbyStations()
        updateFavourites()
        if self.apiState == .loading {
            self.setState(.allGood)
        }
        Helper.log("Service: Completed updateAll()")
    }

    private func updateFavourites() {
        for rentalStation in BikeRentalStationStore.shared.favouriteBikeRentalStations.value
        where !favouriteStationsAlreadyUpdated.contains(rentalStation.stationId) {
            updateRentalStationValuesFromApi(rentalStation: rentalStation)
        }
        BikeRentalStationStore.shared.saveManagedObjectContext()
    }

    private func fetchNearbyStations() {
        guard let userLocation = UserLocationService.shared.userLocation else {
            Log.e("Found nil userLocation when fetching stations from API")
            return
        }
        if apiState == .error { return }

        Network.shared.apollo.fetch(
            query: FetchNearByBikeRentalStationsQuery(
                lat: userLocation.coordinate.latitude,
                lon: userLocation.coordinate.longitude,
                maxDistance: UserDefaultsService.shared.nearbyDistance
            )
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let edgesUnwrapped = graphQLResult.data?.nearest?.edges?.compactMap({ $0 }) else {
                    Log.d("Found nil when unwrapping edges array from API call")
                    return
                }

                let nearbyRentalStationsFromApi = self.edgesFromApiToArrayOfRentalStations(
                    edgesFromApi: edgesUnwrapped
                )
                BikeRentalStationStore.shared.nearbyBikeRentalStations.value = nearbyRentalStationsFromApi
            case .failure(let error):
                Helper.log("API Fecth failed: \(error)")
            }
        }
    }

    /// Converts API result array to an array of RentalStations. If favourite stations are encountered
    /// the BikeRentalStation object is fetched from CoreData, the values are updated and
    /// the station is added to the list of nearby rental stations that is returned
    /// - Parameter edgesFromApi: Nearby bike rental stations from the API
    /// - Returns: [RentalStation]
    private func edgesFromApiToArrayOfRentalStations(
        edgesFromApi: [FetchNearByBikeRentalStationsQuery.Data.Nearest.Edge]
    ) -> [RentalStation] {

        var nearbyRentalStationsFromApi: [RentalStation] = []

        for edge in edgesFromApi {
            // Check if station already exists in Core Data
            if let bikeRentalStationFromCoreData = BikeRentalStationStore.shared.bikeRentalStationFromCoreData(
                stationId: edge.node?.place?.asBikeRentalStation?.stationId
            ) {
                // RentalStation found in CoreData, updating values and adding info to favouriteStationsAlreadyUpdated
                bikeRentalStationFromCoreData.updateValues(apiResultMapOptional: edge.node?.place!.resultMap)
                favouriteStationsAlreadyUpdated.insert(bikeRentalStationFromCoreData.stationId)
                nearbyRentalStationsFromApi.append(bikeRentalStationFromCoreData)
            } else {
                // Creating new RentalStation object
                if let bikeRentalStationUnmanaged = UnmanagedBikeRentalStation(
                    apiResultMapOptional: edge.node?.place!.resultMap
                ) {
                    nearbyRentalStationsFromApi.append(bikeRentalStationUnmanaged)
                }
            }
        }

        return nearbyRentalStationsFromApi
    }

    private func updateRentalStationValuesFromApi(rentalStation: RentalStation) {
        Network.shared.apollo.fetch(query: FetchBikeRentalStationByStationIdQuery(
            stationId: rentalStation.stationId
            )
        ) { result in
            switch result {
            case .success(let graphQlResult):
                rentalStation.updateValues(
                    apiResultMapOptional: graphQlResult.data?.bikeRentalStation?.resultMap
                )
            case .failure(let error):
                Log.e("GraphQl error: \(error)")
            }
        }
    }

    private func setState(_ newApiState: ApiState) {
        if apiState != newApiState {
            apiState = newApiState
        }
    }
}

// MARK: - ReachabilityObserverDelegate
extension BikeRentalStationAPI: ReachabilityObserverDelegate {

    func reachabilityChanged(_ isReachable: Bool) {
        if isReachable {
            if apiState == .error {
                setState(.allGood)
            }
            return
        }
        setState(.error)
    }

}
