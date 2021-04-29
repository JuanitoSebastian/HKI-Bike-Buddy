//
//  UserDefaultStoreTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 26.4.2021.
//
@testable import HKIBikeBuddy
import XCTest

class UserDefaultStoreTests: XCTestCase {

    let userDefaultStore = UserDefaultsStore.shared

    override func tearDown() {
        userDefaultStore.nearbyRadius = 1000
        userDefaultStore.locationServicesPromptDisplayed = false
    }

    func test_a_neraby_radius_initial_value() {
        XCTAssertEqual(userDefaultStore.nearbyRadius, 1000)
    }

    func test_b_nearby_radius_set_and_read_value() {
        userDefaultStore.nearbyRadius = 2000
        XCTAssertEqual(userDefaultStore.nearbyRadius, 2000)
    }

    func test_c_locationServicesPromptDisplayed_initial_value() {
        XCTAssertEqual(userDefaultStore.locationServicesPromptDisplayed, false)
    }

    func test_d_locationServicesPromptDisplayed_set_and_read_value() {
        userDefaultStore.locationServicesPromptDisplayed = true
        XCTAssertEqual(userDefaultStore.locationServicesPromptDisplayed, true)
    }

}
