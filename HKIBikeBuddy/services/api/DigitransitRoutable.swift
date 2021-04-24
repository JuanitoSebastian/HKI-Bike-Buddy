//
//  DigitransitRoutingApi.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 22.4.2021.
//

import Foundation

enum DigitransitRoutable: Routable {

    case fetchBikeRentalStation(stationId: String)
    case fetchNearbyBikeRentalStations(lat: Double, lon: Double, nearbyRadius: Int)

    var url: URL {
        URL(string: "https://api.digitransit.fi/routing/v1/routers/hsl/index/" + self.endPoint)!
    }

    var method: HTTPMethod {
        switch self {
        default: return HTTPMethod.POST
        }
    }

    var endPoint: String {
        switch self {
        default: return "graphql"
        }
    }

    var headers: [String: String] {
        switch self {
        default:
            return ["Content-Type": "application/json", "User-Agent": "HkiBikeBuddy"]
        }
    }

    var body: Data? {
        switch self {

        case .fetchNearbyBikeRentalStations(let lat, let lon, let nearbyRadius):
            var data = Data()
            let parameter = [
                            "query": """
                                {
                                  nearest(lat: \(lat), lon: \(lon), maxDistance: \(nearbyRadius), filterByPlaceTypes: BICYCLE_RENT) {
                                    edges {
                                      node {
                                        place {
                                            ...on BikeRentalStation {
                                                stationId
                                                name
                                                bikesAvailable
                                                spacesAvailable
                                                lat
                                                lon
                                                allowDropoff
                                                state
                                            }
                                        }
                                        distance
                                      }
                                    }
                                  }
                                }
                                """
            ] as [String: Any]
            do {
                data = try JSONSerialization.data(withJSONObject: parameter, options: [])
            } catch {
                data = Data()
            }
            return data

        case .fetchBikeRentalStation(let stationId):
            var data = Data()
            let parameter = [
                            "query": """
                                {
                                  bikeRentalStation(id:"\(stationId)") {
                                    stationId
                                    name
                                    bikesAvailable
                                    spacesAvailable
                                    lat
                                    lon
                                    allowDropoff
                                    state
                                  }
                                }
                                """
            ] as [String: Any]
            do {
                data = try JSONSerialization.data(withJSONObject: parameter, options: [])
            } catch {
                data = Data()
            }
            return data
        }

    }

    var request: URLRequest {
        switch self {

        case .fetchBikeRentalStation:
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = body
            return request

        case .fetchNearbyBikeRentalStations:
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = body
            return request
        }
    }
}
