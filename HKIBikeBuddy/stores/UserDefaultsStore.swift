//
//  UserSettingsManager.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 5.3.2021.
//

import Foundation

/// Saves default values to the UserDefaults store. Access via singleton.
class UserDefaultsStore {

    // Singleton instance
    public static let shared = UserDefaultsStore()

    private let userDefaults: UserDefaults

    private init() {
        self.userDefaults = UserDefaults()
    }

    /// Maximum distance for bike rental station to be considered nearby
    /// If the user has not set this from settings a default value of 1000 m is returned
    var nearbyRadius: Int {
        get {
            let fetch = userDefaults.integer(forKey: "nearbyDistance")
            return fetch != 0 ? fetch : 1000
        }
        set(newValue) {
            userDefaults.setValue(newValue, forKey: "nearbyDistance")
        }
    }

    /// This value is set to true when the system location authorization pop-up has been displayed.
    /// Value is set to true when UserLocationService.shared.requestLocationServicesPermission() has been called.
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
