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
        let completition: () -> Void =
            BikeRentalStationStore.shared.favouriteBikeRentalStations.value.isEmpty ? { self.setState(.ready) } : {}
        fetchNearbyStationsFromApiToStore(completition: completition)
        updateFavourites()
        Log.i("Completed updateStoreWithAPI()")
    }

    private func updateFavourites() {
        let numberOfStationsToUpdate =
            BikeRentalStationStore.shared.favouriteBikeRentalStations.value.count -
            favouriteStationsAlreadyUpdated.count
        var stationsUpdated = 0
        Log.i("Stations to update: \(numberOfStationsToUpdate)")

        if numberOfStationsToUpdate == 0 {
            self.setState(.ready)
            BikeRentalStationStore.shared.saveManagedObjectContext()
            return
        }

        for rentalStation in BikeRentalStationStore.shared.favouriteBikeRentalStations.value
        where !favouriteStationsAlreadyUpdated.contains(rentalStation.stationId) {
            Log.i("in loop")
            stationsUpdated += 1
            if stationsUpdated == numberOfStationsToUpdate {
                updateRentalStationValuesFromApi(rentalStation: rentalStation, completition: {
                    self.setState(.ready)
                    BikeRentalStationStore.shared.saveManagedObjectContext()
                })
            } else {
                updateRentalStationValuesFromApi(rentalStation: rentalStation, completition: {})
            }
        }
    }

    private func fetchNearbyStationsFromApiToStore(completition: @escaping () -> Void) {
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
                BikeRentalStationStore.shared.nearbyBikeRentalStations.value = nearbyRentalStationsFromApi
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
                // Rental Station not found in CoreData, creating new UnmanagedRentalStation
                if let bikeRentalStationUnmanaged = UnmanagedBikeRentalStation(
                    apiResultMapOptional: edge.node?.place!.resultMap
                ) {
                    nearbyRentalStationsFromApi.append(bikeRentalStationUnmanaged)
                }
            }
        }

        return nearbyRentalStationsFromApi
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
