//
//  DoubleTests.swift
//  HkiBikeBuddyLogicTests
//
//  Created by Juan Covarrubias on 27.4.2021.
//

@testable import HKIBikeBuddy
import XCTest

class DoubleTests: XCTestCase {

    func test_a_round_to_nearest() {
        XCTAssertEqual(Double.roundToNearest(123.38987, toNearest: 20), 120)
        XCTAssertEqual(Double.roundToNearest(-89, toNearest: 100), -100)
        XCTAssertEqual(Double.roundToNearest(9, toNearest: 20), 0)
    }

}
