//
//  SettingsViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.3.2021.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {

    @Published var nearbyRange: Double = Double(UserDefaultsService.shared.nearbyDistance)

    var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    var nearbyRangeInt: Int {
        Int(nearbyRange)
    }

    var juanUrl: URL {
        URL(string: "https://juan.fi")!
    }

    public static var shared = SettingsViewModel()

    func saveSettings() {
        UserDefaultsService.shared.nearbyDistance = nearbyRangeInt
        BikeRentalStationAPI.shared.updateStoreWithAPI()
    }

    func openJuanitoHomepage() {
        UIApplication.shared.open(juanUrl, options: [:], completionHandler: nil)
    }

}
