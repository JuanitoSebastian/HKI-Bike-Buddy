//
//  Date.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 19.4.2021.
//

import Foundation

extension Date {

    /// Determines if a given date is X seconds away from the curent moment
    /// - Parameter dateInPast: The date we need the information on
    /// - Parameter seconds: Amount of seconds
    static func isDateWithinSecondsFromNow(dateInPast: Date, seconds: Double) -> Bool {
        let range = seconds < 0 ?
            Date().addingTimeInterval(seconds)...Date() :
            Date()...Date().addingTimeInterval(seconds)
        return range.contains(dateInPast)
    }

}
