//
//  DateExtensionTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 27.4.2021.
//

@testable import HKIBikeBuddy
import XCTest

class DateExtensionTests: XCTestCase {

    func test_a_date_within_seconds_from_now_past() {
        let past = Date().addingTimeInterval(-5)

        XCTAssertTrue(Date.isDateWithinSecondsFromNow(past, seconds: -10))
        XCTAssertFalse(Date.isDateWithinSecondsFromNow(past, seconds: -4))

    }

    func test_b_date_withing_seconds_from_now_future() {
        let future = Date().addingTimeInterval(1000)

        XCTAssertFalse(Date.isDateWithinSecondsFromNow(future, seconds: -10))
        XCTAssertTrue(Date.isDateWithinSecondsFromNow(future, seconds: 1000))
    }

}
