//
//  ContentViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {

    @Published var navigationSelection = BikeRentalStationStore.shared.favouriteBikeRentalStations.value.isEmpty ?
        MainViewNavigation.nearbyStations : MainViewNavigation.myStations
    @Published var appState = MainViewContent.navigationView
    var timer: Timer?

    public static let shared = ContentViewModel()

    var title: String {
        switch navigationSelection {
        case .nearbyStations: return "Nearby Stations"
        case .myStations: return "My Stations"
        case .settings: return "Settings"
        }
    }

    func startUpdateTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 30,
            target: self,
            selector: #selector(updateStations),
            userInfo: nil,
            repeats: true
        )
    }

    func stopUpdateTimer() {
        timer = nil
    }

    @objc
    func updateStations() {
        if UserLocationService.shared.locationAuthorization == .success {
            BikeRentalService.shared.updateAll()
        }
    }

}

enum MainViewNavigation: Int, Codable {
    case nearbyStations
    case myStations
    case settings
}

enum MainViewContent {
    case navigationView
    case detailedStationView
    case overlayContent
    case loading
    case error(String)
}
