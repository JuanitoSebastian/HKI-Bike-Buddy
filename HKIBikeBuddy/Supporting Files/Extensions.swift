//
//  Extensions.swift
//  HKIBikeBuddy
//
//  Created by Juan Covarrubias on 7.5.2021.
//

import Foundation

// MARK: - Double
extension Double {

    /// Rounds a value to a given accuracy
    /// - Parameter value: the number to round
    /// - Parameter toNearest: value is rounded to the nearest multiple of this value
    static func roundToNearest(_ value: Double, toNearest: Double) -> Double {
        return (value / toNearest).rounded() * toNearest
    }
}

// MARK: - Date
extension Date {

    /// Determines if a given date is X seconds away from the curent moment
    /// - Parameter date: The date we need the information on
    /// - Parameter seconds: Amount of seconds
    static func isDateWithinSecondsFromNow(_ date: Date, seconds: Double) -> Bool {
        let range = seconds < 0 ?
            Date().addingTimeInterval(seconds)...Date() :
            Date()...Date().addingTimeInterval(seconds)
        return range.contains(date)
    }

}
