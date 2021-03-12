//
//  SettingsViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.3.2021.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {

    @Published var nearbyRange: Double = Double(UserSettingsManager.shared.nearbyDistance)
    @Published var nearbyRangeEditing: Bool = false

    var nearbyRangeInt: Int {
        Int(nearbyRange)
    }

    public static var shared = SettingsViewModel()

    func saveSettings() {
        UserSettingsManager.shared.nearbyDistance = nearbyRangeInt
        BikeRentalService.shared.fetchNearbyStations()
    }

}
