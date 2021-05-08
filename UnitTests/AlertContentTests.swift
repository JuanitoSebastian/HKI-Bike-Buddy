//
//  AlertContentTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 29.4.2021.
//

import XCTest
import SwiftUI
@testable import HKIBikeBuddy

class AlertContentTests: XCTestCase {

    func test_a_create_alert() {
        let title = LocalizedStringKey("AlertTitle")
        let message = LocalizedStringKey("AlertMessage")
        let type = AlertContent.AlertType.notice

        let alert = AlertContent(
            title: title,
            message: message,
            type: type
        )

        XCTAssertEqual(title, alert.title)
        XCTAssertEqual(message, alert.message)
        XCTAssertEqual(type, alert.type)
    }

    func test_b_no_internet_alert() {
        let alert = AlertContent.noInternet
        XCTAssertEqual(LocalizedStringKey("alertTitleNetworkError"), alert.title)
        XCTAssertEqual(LocalizedStringKey("alertMessageNetworkError"), alert.message)
        XCTAssertEqual(.actionable, alert.type)
        XCTAssertEqual(LocalizedStringKey("alertButtonTryAgain"), alert.actionableButtonText)
    }

    func test_c_fetch_failed_alert() {
        let alert = AlertContent.fetchError
        XCTAssertEqual(LocalizedStringKey("alertTitleApiError"), alert.title)
        XCTAssertEqual(LocalizedStringKey("alertMessageApiError"), alert.message)
        XCTAssertEqual(.actionable, alert.type)
        XCTAssertEqual(LocalizedStringKey("alertButtonTryAgain"), alert.actionableButtonText)
    }

    func test_d_no_location() {
        let alert = AlertContent.noLocation
        XCTAssertEqual(LocalizedStringKey("alertTitleLocationError"), alert.title)
        XCTAssertEqual(LocalizedStringKey("alertMessageLocationError"), alert.message)
        XCTAssertEqual(.notice, alert.type)
    }

    func test_e_store_load_failure_alert() {
        let alert = AlertContent.failedToLoadStore
        XCTAssertEqual(LocalizedStringKey("alertTitleStoreLoadError"), alert.title)
        XCTAssertEqual(LocalizedStringKey("alertMessageStoreLoadError"), alert.message)
        XCTAssertEqual(.actionable, alert.type)
        XCTAssertEqual(LocalizedStringKey("alertButtonTryAgain"), alert.actionableButtonText)
    }

    func test_f_store_save_failure_alert() {
        let alert = AlertContent.failedToSaveStore
        XCTAssertEqual(LocalizedStringKey("alertTitleStoreSaveError"), alert.title)
        XCTAssertEqual(LocalizedStringKey("alertMessageStoreSaveError"), alert.message)
        XCTAssertEqual(.actionable, alert.type)
        XCTAssertEqual(LocalizedStringKey("alertButtonTryAgain"), alert.actionableButtonText)
    }

}
