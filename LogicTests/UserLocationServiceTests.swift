//
//  UserLocationServiceTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 26.4.2021.
//
@testable import HKIBikeBuddy
import XCTest
import CoreLocation

class UserLocationServiceTests: XCTestCase {

    let userLocationService = UserLocationService.shared
    let timeout: TimeInterval = 10

    func test_a_publishing_of_location_authorization() {
        let expectation = self.expectation(description: "Awaiting publisher")

        userLocationService.setLocationAuthorization(authorization: .success)

        _ = userLocationService.$locationAuthorization.eraseToAnyPublisher().sink { receivedValue in
            if receivedValue == .success {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_b_publishing_of_location() {
        let expectation = self.expectation(description: "Awaiting publisher")

        let location = CLLocation(latitude: 60.184569, longitude: 24.949303)
        userLocationService.setUserLocation(location: location)

        _ = userLocationService.$userLocation.eraseToAnyPublisher().sink { receivedValue in

            if receivedValue == location {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: timeout)
    }

    func test_c_user_location_2d() {
        userLocationService.setUserLocation(location: CLLocation(latitude: 60.184569, longitude: 24.949303))
        XCTAssertEqual(
            userLocationService.userLocation!.coordinate.latitude,
            userLocationService.userLocation2D?.latitude
        )
        XCTAssertEqual(
            userLocationService.userLocation!.coordinate.longitude,
            userLocationService.userLocation2D?.longitude
        )
    }

}
