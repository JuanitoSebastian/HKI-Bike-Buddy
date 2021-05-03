//
//  Double.swift
//  HKIBikeBuddy
//
//  Created by Juan Covarrubias on 27.4.2021.
//

import Foundation

extension Double {

    /// Rounds a value to a given accuracy
    /// - Parameter value: the number to round
    /// - Parameter toNearest: value is rounded to the nearest multiple of this value
    static func roundToNearest(_ value: Double, toNearest: Double) -> Double {
        return (value / toNearest).rounded() * toNearest
    }
}
