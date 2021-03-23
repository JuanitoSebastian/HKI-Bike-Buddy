//
//  UserSettingsManager.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 5.3.2021.
//

import Foundation

class UserDefaultsService {

    public static let shared = UserDefaultsService()

    private let userDefaults = UserDefaults()

    var nearbyDistance: Int {
        get {
            let fetch = userDefaults.integer(forKey: "nearbyDistance")
            return fetch != 0 ? fetch : 1000
        }
        set(newValue) {
            userDefaults.setValue(newValue, forKey: "nearbyDistance")
        }
    }

    var locationServicesPromptDisplayed: Bool {
        get {
            let fetch = userDefaults.bool(forKey: "locationServices")
            return fetch
        }
        set(newValue) {
            userDefaults.setValue(newValue, forKey: "locationServices")
        }
    }

}
