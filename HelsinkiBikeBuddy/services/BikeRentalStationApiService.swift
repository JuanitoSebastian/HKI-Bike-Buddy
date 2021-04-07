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
    private var alreadyUpdatedStationIds: Set<String>

    // Singleton instance
    static let shared = BikeRentalStationApiService()

    private init() {
        self.apiReachabilityState = .undetermined
        self.apiOperationState = .loading
        self.alreadyUpdatedStationIds = []
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
        alreadyUpdatedStationIds = []
        setState(.loading)
        fetchNearbyStationsFromApiToStore()
        updateFavourites()
        Log.i("Completed updateStoreWithAPI()")
    }

    private func updateFavourites() {
        for stationId in RentalStationStore.shared.bikeRentalStationIds.value
        where !alreadyUpdatedStationIds.contains(stationId) {
            guard let bikeRentalStationToUpdate = RentalStationStore.shared.bikeRentalStations[stationId]
            else { return }
            updateRentalStationValuesFromApi(
                bikeRentalStationToUpdate,
                completition: {})
        }
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

                let newBikeRentalStationsFromApi = self.edgesFromApiToArrayOfRentalStations(
                    edgesFromApi: edgesUnwrapped
                )

                RentalStationStore.shared.addBikeRentalStations(newBikeRentalStationsFromApi)
            case .failure(let error):
                Log.e("API Fecth failed: \(error)")
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
    ) -> [BikeRentalStation] {

        var newRentalStationsFromApi: [BikeRentalStation] = []

        for edge in edgesFromApi {
            // Checking if station already present at store
            guard let apiStationId = edge.node?.place?.asBikeRentalStation?.stationId else { continue }
            if let rentalStationFromStore =
                RentalStationStore.shared.bikeRentalStations[apiStationId] {
                // Updating existing station
                rentalStationFromStore.updateValues(
                    apiResultMapOptional: edge.node?.place!.resultMap
                )
            } else {
                if let bikeRentalStation = BikeRentalStation(
                    apiResultMapOptional: edge.node?.place!.resultMap
                ) {
                    // Creating a new station object
                    bikeRentalStation.favourite = RentalStationStore.shared.isStationFavourite(stationId: apiStationId)
                    newRentalStationsFromApi.append(bikeRentalStation)
                }
            }
            alreadyUpdatedStationIds.insert(apiStationId)
        }
        setState(.ready)
        return newRentalStationsFromApi
    }

    /// Updates values of a RentalSation that is passed as a parameter
    /// - Parameter rentalStation: RentalStation that should be updated
    private func updateRentalStationValuesFromApi(
        _ bikeRentalStationToUpdate: BikeRentalStation,
        completition: @escaping () -> Void
    ) {
        ApolloNetworkClient.shared.apollo.fetch(query: FetchBikeRentalStationByStationIdQuery(
            stationId: bikeRentalStationToUpdate.stationId
        )
        ) { result in
            switch result {
            case .success(let graphQlResult):
                bikeRentalStationToUpdate.updateValues(
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
