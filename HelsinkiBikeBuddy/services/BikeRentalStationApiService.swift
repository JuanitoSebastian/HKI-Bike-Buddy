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
    private var dispatchGroup = DispatchGroup()

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
        alreadyUpdatedStationIds = []
        setState(.loading)
        fetchNearbyStationsFromApiToStore()
        updateFavourites()
        dispatchGroup.notify(queue: .main) {
            self.setState(.ready)
        }
    }

    private func updateFavourites() {
        for stationId in BikeRentalStationStore.shared.bikeRentalStationIds.value
        where !alreadyUpdatedStationIds.contains(stationId) {
            guard let bikeRentalStationToUpdate = BikeRentalStationStore.shared.bikeRentalStations[stationId]
            else { return }
            dispatchGroup.enter()
            updateRentalStationValuesFromApi(
                bikeRentalStationToUpdate,
                completion: { self.dispatchGroup.leave() })
        }
    }

    private func fetchNearbyStationsFromApiToStore() {
        guard let userLocation = UserLocationService.shared.userLocation else {
            Log.e("Found nil userLocation when fetching stations from API")
            return
        }
        dispatchGroup.enter()
        ApolloNetworkClient.shared.apollo.fetch(
            query: FetchNearByBikeRentalStationsQuery(
                lat: userLocation.coordinate.latitude,
                lon: userLocation.coordinate.longitude,
                maxDistance: UserDefaultsService.shared.nearbyDistance
            ),
            cachePolicy: .fetchIgnoringCacheCompletely
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

                BikeRentalStationStore.shared.addBikeRentalStations(newBikeRentalStationsFromApi)
            case .failure(let error):
                Log.e("API Fecth failed: \(error)")
                AppState.shared.notification = NotificationContent(
                    title: "Network error",
                    text: "Failed to fetch nearby stations from API"
                )
            }
            self.dispatchGroup.leave()
        }
    }

    /// Converts API result array to an array of BikeRentalStations
    /// - Parameter edgesFromApi: Nearby bike rental stations from the API
    /// - Returns: array of BikeRentalStations parsed from edges provided by API
    private func edgesFromApiToArrayOfRentalStations(
        edgesFromApi: [FetchNearByBikeRentalStationsQuery.Data.Nearest.Edge]
    ) -> [BikeRentalStation] {

        var newRentalStationsFromApi: [BikeRentalStation] = []

        for edge in edgesFromApi {
            // Checking if station already present at store
            guard let apiStationId = edge.node?.place?.asBikeRentalStation?.stationId else { continue }
            if let rentalStationFromStore =
                BikeRentalStationStore.shared.bikeRentalStations[apiStationId] {
                // Updating existing station
                rentalStationFromStore.updateValues(
                    apiResultMapOptional: edge.node?.place!.resultMap
                )
            } else {
                if let bikeRentalStation = BikeRentalStation(
                    apiResultMapOptional: edge.node?.place!.resultMap
                ) {
                    // Creating a new station object
                    bikeRentalStation.favourite = BikeRentalStationStore.shared.isStationFavourite(stationId: apiStationId)
                    newRentalStationsFromApi.append(bikeRentalStation)
                }
            }
            alreadyUpdatedStationIds.insert(apiStationId)
        }
        return newRentalStationsFromApi
    }

    /// Updates values of a RentalSation that is passed as a parameter
    /// - Parameter bikeRentalStationToUpdate: Bike Rental Station to update
    /// - Parameter completion: Code block to call when ready
    func updateRentalStationValuesFromApi(
        _ bikeRentalStationToUpdate: BikeRentalStation,
        completion: @escaping () -> Void = {}
    ) {
        ApolloNetworkClient.shared.apollo.fetch(query: FetchBikeRentalStationByStationIdQuery(
            stationId: bikeRentalStationToUpdate.stationId
        ), cachePolicy: .fetchIgnoringCacheCompletely
        ) { result in
            switch result {
            case .success(let graphQlResult):
                bikeRentalStationToUpdate.updateValues(
                    apiResultMapOptional: graphQlResult.data?.bikeRentalStation?.resultMap
                )
            case .failure(let error):
                Log.e("GraphQL Error: \(error)")
                AppState.shared.notification = NotificationContent(
                    title: "Network error",
                    text: "Failed to update stations with API"
                )
            }
            completion()
        }
    }

    /// Fetches a BikeRentalStation from API with stationId
    /// - Parameter stationId: StationId of BikeRentalStation
    /// - Parameter completion: Completion code block to call when station fethed
    func fetchStationFromApi(
        _ stationId: String,
        completion: @escaping (BikeRentalStation?) -> Void
    ) {
        ApolloNetworkClient.shared.apollo.fetch(query: FetchBikeRentalStationByStationIdQuery(
            stationId: stationId
        ), cachePolicy: .fetchIgnoringCacheCompletely
        ) { result in
            switch result {
            case .success(let graphQlResult):
                let bikeRentalStation = BikeRentalStation(
                    apiResultMapOptional: graphQlResult.data?.bikeRentalStation?.resultMap
                )
                completion(bikeRentalStation)

            case .failure(let error):
                Log.e("GraphQL Error: \(error)")
                completion(nil)
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
        if !isReachable {
            AppState.shared.notification = NotificationContent(
                title: "Network error",
                text: "No network connection 😔"
            )
        }
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
