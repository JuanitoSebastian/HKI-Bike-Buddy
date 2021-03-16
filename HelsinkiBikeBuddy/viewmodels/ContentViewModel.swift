//
//  ContentViewModel.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {

    @Published var navigationSelection = MainViewNavigation.myStations
    @Published var appState = MainViewContent.navigationView

    public static let shared = ContentViewModel()

    private init() {
        BikeRentalService.shared.updateAll()
        BikeRentalService.shared.setTimer()
    }

    var title: String {
        switch navigationSelection {
        case .nearbyStations: return "Nearby Stations"
        case .myStations: return "My Stations"
        case .settings: return "Settings"
        }
    }

    var blurAmount: CGFloat {
        switch appState {
        case .overlayContent:
            return 10
        default:
            return 0
        }
    }

    var brightnessAmount: Double {
        switch appState {
        case .overlayContent:
            return -0.01
        default:
            return 0
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
