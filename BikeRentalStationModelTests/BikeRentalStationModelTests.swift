//
//  BikeRentalStationModelTests.swift
//  BikeRentalStationModelTests
//
//  Created by Juan Covarrubias on 9.2.2021.
//

import XCTest
import CoreData
import HelsinkiBikeBuddy

class BikeRentalStationModelTests: XCTestCase {

    func test_BikeRentalStation_stationId() throws {
        XCTAssertThrowsError(try BikeRentalStation.validateStationId(""))
        XCTAssertThrowsError(try BikeRentalStation.validateStationId("12345"))
        XCTAssertThrowsError(try BikeRentalStation.validateStationId("lol"))
        XCTAssertThrowsError(try BikeRentalStation.validateStationId("12"))
        XCTAssertNoThrow(try BikeRentalStation.validateStationId("123"))
        XCTAssertNoThrow(try BikeRentalStation.validateStationId("1234"))
    }

    func test_BikeRentalStation_name() throws {
        XCTAssertThrowsError(try BikeRentalStation.validateName(""))
        XCTAssertThrowsError(try BikeRentalStation.validateName(
                                "Tutustu tehtäviä varten Rossin kirjan lukuun 5, erityisesti lukuihin 5.1-5.7"
        ))
        XCTAssertNoThrow(try BikeRentalStation.validateName("Kajanuksenkatu"))
    }

    func test_BikeRentalStation_coordinates() throws {
        XCTAssertThrowsError(try BikeRentalStation.validateCoordinates(lat: 100, lon: -22))
        XCTAssertNoThrow(try BikeRentalStation.validateCoordinates(lat: 90, lon: 55.44545))
    }

}
