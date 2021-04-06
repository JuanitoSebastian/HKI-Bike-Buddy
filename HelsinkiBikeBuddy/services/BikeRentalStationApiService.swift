//
//  BikeRentalService.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 12.2.2021.
//

import Foundation
import Apollo
import ApolloWebSocket

// MARK: - Initiation of class
class BikeRentalStationApiService: ObservableObject {

    @Published var apiReachabilityState: ApiReachabilityState
    @Published var apiOperationState: ApiOperationState
    private var favouriteStationsAlreadyUpdated: Set<String>

    // Singleton instance
    static let shared = BikeRentalStationApiService()

    private init() {
        self.apiReachabilityState = .undetermined
        self.apiOperationState = .loading
        self.favouriteStationsAlreadyUpdated = []
        try? addReachabilityObserver()
    }

    deinit {
        removeReachabilityObserver()
    }
}

// MARK: - Fetching and updating of stations
extension BikeRentalStationApiService {

    /// Updates the list of nearby stations in BikeRentalStationStore with an up-to-date version from API and
    /// updates favourite stations with up-to-date data from API
    @objc
    func updateStoreWithAPI() {
        Log.i("Starting updateStoreWithAPI()")
        favouriteStationsAlreadyUpdated.removeAll()
        setState(.loading)

        fetchNearbyStationsFromApiToStore()
        updateFavourites()
        Log.i("Completed updateStoreWithAPI()")
    }

    private func updateFavourites() {

    }

    private func fetchNearbyStationsFromApiToStore() {
        guard let userLocation = UserLocationService.shared.userLocation else {
            Log.e("Found nil userLocation when fetching stations from API")
            return
        }

        ApolloNetworkClient.shared.apollo.fetch(
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
                BikeRentalStationStore.shared.addStations(rentalStations: nearbyRentalStationsFromApi)
            case .failure(let error):
                Helper.log("API Fecth failed: \(error)")
            }
        }
    }

    /// Converts API result array to an array of RentalStations. If favourite stations are encountered
    /// the ManagedBikeRentalStation object is fetched from CoreData, the values are updated and
    /// the station is added to the list of nearby rental stations that is returned
    /// - Parameter edgesFromApi: Nearby bike rental stations from the API
    /// - Returns: array of RentalStations parsed from edges provided by API
    private func edgesFromApiToArrayOfRentalStations(
        edgesFromApi: [FetchNearByBikeRentalStationsQuery.Data.Nearest.Edge]
    ) -> [RentalStation] {

        var newRentalStationsFromApi: [RentalStation] = []

        for edge in edgesFromApi {
            // Check if station already exists in Core Data
            guard let apiStationId = edge.node?.place?.asBikeRentalStation?.stationId else { continue }
            if let rentalStationFromStore =
                BikeRentalStationStore.shared.bikeRentalStations[apiStationId] {
                rentalStationFromStore.updateValues(
                    apiResultMapOptional: edge.node?.place!.resultMap
                )
            } else {
                if let unmanagedRentalStation = UnmanagedBikeRentalStation(
                    apiResultMapOptional: edge.node?.place!.resultMap
                ) {
                    newRentalStationsFromApi.append(unmanagedRentalStation)
                }
            }
        }

        return newRentalStationsFromApi
    }

    /// Updates values of a RentalSation that is passed as a parameter
    /// - Parameter rentalStation: RentalStation that should be updated
    private func updateRentalStationValuesFromApi(
        rentalStation: RentalStation,
        completition: @escaping () -> Void
    ) {
        ApolloNetworkClient.shared.apollo.fetch(query: FetchBikeRentalStationByStationIdQuery(
            stationId: rentalStation.stationId
        )
        ) { result in
            switch result {
            case .success(let graphQlResult):
                rentalStation.updateValues(
                    apiResultMapOptional: graphQlResult.data?.bikeRentalStation?.resultMap
                )
                completition()
            case .failure(let error):
                Log.e("GraphQL Client Error: \(error)")
            }
        }
    }
}

// MARK: - Handling state object
extension BikeRentalStationApiService {

    private func setState(_ newApiOperationState: ApiOperationState) {
        if apiOperationState != newApiOperationState {
            Log.i("BikeRentalStationApiService state \(apiOperationState) -> \(newApiOperationState)")
            apiOperationState = newApiOperationState
        }
    }

}

// MARK: - ReachabilityObserverDelegate
extension BikeRentalStationApiService: ReachabilityObserverDelegate {

    func reachabilityChanged(_ isReachable: Bool) {
        apiReachabilityState = isReachable ? .normal : .error
    }

}

enum ApiReachabilityState: Equatable {
    case normal
    case error
    case undetermined
}

enum ApiOperationState {
    case loading
    case ready
}
