//
//  Helper.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation

import Foundation

class Helper {

    static func log(_ printMe: Any) {
        #if DEBUG
        print(printMe)
        #endif
    }
}
