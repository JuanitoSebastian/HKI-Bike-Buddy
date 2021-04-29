//
//  AlertContentTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 29.4.2021.
//

import XCTest
@testable import HKIBikeBuddy

class AlertContentTests: XCTestCase {

    func test_a_create_alert() {
        let title = "AlertTitle"
        let message = "AlertMessage"
        let type = AlertContent.AlertType.notice

        let alert = AlertContent(
            title: title,
            message: message,
            type: type
        )

        XCTAssertEqual(title, alert.title)
        XCTAssertEqual(message, alert.message)
        XCTAssertEqual(type, alert.type)
        XCTAssertEqual("", alert.actionableButtonText)
    }

    func test_b_no_internet_alert() {
        let alert = AlertContent.noInternet
        XCTAssertEqual("Network Error", alert.title)
        XCTAssertEqual("No internet connection", alert.message)
        XCTAssertEqual(.actionable, alert.type)
        XCTAssertEqual("Try again", alert.actionableButtonText)
    }

    func test_c_fetch_failed_alert() {
        let alert = AlertContent.fetchError
        XCTAssertEqual("Network Error", alert.title)
        XCTAssertEqual("Failed to fetch stations", alert.message)
        XCTAssertEqual(.actionable, alert.type)
        XCTAssertEqual("Try again", alert.actionableButtonText)
    }

    func test_d_fetch_failed_alert() {
        let alert = AlertContent.noLocation
        XCTAssertEqual("Current Location Not Available", alert.title)
        XCTAssertEqual("Your current location could not be determined", alert.message)
        XCTAssertEqual(.notice, alert.type)
        XCTAssertEqual("", alert.actionableButtonText)
    }

    func test_e_store_load_failure_alert() {
        let alert = AlertContent.failedToLoadStore
        XCTAssertEqual("Could Not Load Favourite Stations", alert.title)
        XCTAssertEqual("Failed to load favourite stations from memory", alert.message)
        XCTAssertEqual(.actionable, alert.type)
        XCTAssertEqual("Try again", alert.actionableButtonText)
    }

    func test_f_store_save_failure_alert() {
        let alert = AlertContent.failedToSaveStore
        XCTAssertEqual("Could Not Save Favourite Stations", alert.title)
        XCTAssertEqual("Failed to save favourite stations to memory", alert.message)
        XCTAssertEqual(.actionable, alert.type)
        XCTAssertEqual("Try again", alert.actionableButtonText)
    }

}
