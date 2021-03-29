//
//  Helper.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation

class Helper {

    static func log(_ printMe: Any) {
        #if DEBUG
        print(printMe)
        #endif
    }

    static func timeIntervalToString(_ timeInverval: TimeInterval) -> String {
        if timeInverval < 60 {
            return "\(timeInverval) second"
        }
        var formatted = timeInverval / 60
        formatted.round(.toNearestOrEven)
        return "\(formatted) minute"
    }

    static func roundToNearest(_ value: Double, toNearest: Double) -> Double {
      return round(value / toNearest) * toNearest
    }

    static func isRunningTests() -> Bool {
        return UserDefaults.standard.bool(forKey: "isTest")
    }

    static func parseStateString(_ state: String) -> Bool {
        if state.contains("off") { return false }
        return true
    }

}
