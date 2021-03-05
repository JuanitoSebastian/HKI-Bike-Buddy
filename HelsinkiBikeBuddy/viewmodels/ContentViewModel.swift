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
    @Published var mainViewContent = MainViewContent.navigationView

    var navBarTitle: String {
        switch navigationSelection {
        case .nearbyStations:
            return "Nearby Stations."
        case .myStations:
            return "My Stations."
        case .map:
            return "Map."
        }
    }

    public static let shared = ContentViewModel()

    private init() {
        BikeRentalService.shared.updateAll()
        BikeRentalService.shared.setTimer()
    }

    var blurAmount: CGFloat {
        switch mainViewContent {
        case .detailedStationView:
            return 2
        default:
            return 0
        }
    }

    var brightnessAmount: Double {
        switch mainViewContent {
        case .detailedStationView:
            return -0.2
        default:
            return 0
        }
    }
}

enum MainViewNavigation: Int, Codable {
    case nearbyStations
    case myStations
    case map
}

enum MainViewContent {
    case navigationView
    case detailedStationView
    case loading
}
