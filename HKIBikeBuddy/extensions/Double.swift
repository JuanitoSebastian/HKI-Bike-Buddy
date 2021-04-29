//
//  Double.swift
//  HKIBikeBuddy
//
//  Created by Juan Covarrubias on 27.4.2021.
//

import Foundation

extension Double {

    static func roundToNearest(_ value: Double, toNearest: Double) -> Double {
        return (value / toNearest).rounded() * toNearest
    }
}
