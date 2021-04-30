//
//  DigitransitRoutableTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 30.4.2021.
//

import XCTest
@testable import HKIBikeBuddy

class DigitransitRoutableTests: XCTestCase {

    let stationIdToQuery = "001"
    let stationIdsToQuery = ["001", "114", "044"]
    let lat = 60.170513
    let lon = 24.941526
    let radius = 2500

    func test_a_bike_rental_station() {
        let digitransitRoutable = DigitransitRoutable.fetchBikeRentalStation(stationId: stationIdToQuery)
        let correctQueryString = "{\n  bikeRentalStation(id:\"\(stationIdToQuery)\") {\n    stationId\n    " +
            "name\n    bikesAvailable\n    spacesAvailable\n    lat\n    lon\n    allowDropoff\n    state\n  }\n}"

        XCTAssertEqual(
            digitransitRoutable.url.absoluteString,
            "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"
        )
        XCTAssertEqual(digitransitRoutable.endPoint, "graphql")
        XCTAssertEqual(digitransitRoutable.method, HTTPMethod.POST)
        XCTAssertEqual(digitransitRoutable.headers, ["Content-Type": "application/json", "User-Agent": "HkiBikeBuddy"])

        let requestBodyDictionary = try? JSONDecoder().decode([String: String].self, from: digitransitRoutable.body!)
        XCTAssertNotNil(requestBodyDictionary)

        let queryString = requestBodyDictionary!["query"]
        XCTAssertNotNil(queryString)
        XCTAssertEqual(queryString, correctQueryString)

        XCTAssertEqual(digitransitRoutable.request.httpMethod, digitransitRoutable.method.rawValue)
        XCTAssertEqual(digitransitRoutable.request.httpBody, digitransitRoutable.body)
        XCTAssertEqual(digitransitRoutable.request.httpMethod, digitransitRoutable.method.rawValue)
    }

    func test_b_nearby_bike_rental_stations() {
        let digitransitRoutable = DigitransitRoutable.fetchNearbyBikeRentalStations(
            lat: lat,
            lon: lon,
            nearbyRadius: radius
        )
        let correctQueryString = "{\n  nearest(lat: \(lat), lon: \(lon), maxDistance: \(radius), " +
            "filterByPlaceTypes: BICYCLE_RENT) {\n    edges {\n      node {\n        place {\n" +
            "            ...on BikeRentalStation {\n                stationId\n                " +
            "name\n                bikesAvailable\n                spacesAvailable\n" +
            "                lat\n                lon\n                allowDropoff\n" +
            "                state\n            }\n        }\n        distance\n      }\n    }\n  }\n}"

        XCTAssertEqual(
            digitransitRoutable.url.absoluteString,
            "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"
        )
        XCTAssertEqual(digitransitRoutable.endPoint, "graphql")
        XCTAssertEqual(digitransitRoutable.method, HTTPMethod.POST)
        XCTAssertEqual(digitransitRoutable.headers, ["Content-Type": "application/json", "User-Agent": "HkiBikeBuddy"])

        let requestBodyDictionary = try? JSONDecoder().decode([String: String].self, from: digitransitRoutable.body!)
        XCTAssertNotNil(requestBodyDictionary)

        let queryString = requestBodyDictionary!["query"]
        XCTAssertNotNil(queryString)
        XCTAssertEqual(queryString, correctQueryString)

        XCTAssertEqual(digitransitRoutable.request.httpMethod, digitransitRoutable.method.rawValue)
        XCTAssertEqual(digitransitRoutable.request.httpBody, digitransitRoutable.body)
        XCTAssertEqual(digitransitRoutable.request.httpMethod, digitransitRoutable.method.rawValue)

    }

    func test_c_bike_rental_stations() {
        let digitransitRoutable = DigitransitRoutable.fetchBikeRentalStations(stationIds: stationIdsToQuery)
        let correctQueryString = "{\n  bikeRentalStations(ids: \(stationIdsToQuery)) " +
            "{\n    stationId\n    name\n    bikesAvailable\n    spacesAvailable\n    lat\n" +
            "    lon\n    allowDropoff\n    state\n  }\n}\n"

        XCTAssertEqual(
            digitransitRoutable.url.absoluteString,
            "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"
        )
        XCTAssertEqual(digitransitRoutable.endPoint, "graphql")
        XCTAssertEqual(digitransitRoutable.method, HTTPMethod.POST)
        XCTAssertEqual(digitransitRoutable.headers, ["Content-Type": "application/json", "User-Agent": "HkiBikeBuddy"])

        let requestBodyDictionary = try? JSONDecoder().decode([String: String].self, from: digitransitRoutable.body!)
        XCTAssertNotNil(requestBodyDictionary)

        let queryString = requestBodyDictionary!["query"]
        XCTAssertNotNil(queryString)
        XCTAssertEqual(queryString, correctQueryString)

        XCTAssertEqual(digitransitRoutable.request.httpMethod, digitransitRoutable.method.rawValue)
        XCTAssertEqual(digitransitRoutable.request.httpBody, digitransitRoutable.body)
        XCTAssertEqual(digitransitRoutable.request.httpMethod, digitransitRoutable.method.rawValue)
    }

}
