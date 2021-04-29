//
//  Helper.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation

class Helper {

    static func isRunningTests() -> Bool {
        return UserDefaults.standard.bool(forKey: "isTest")
    }

}
