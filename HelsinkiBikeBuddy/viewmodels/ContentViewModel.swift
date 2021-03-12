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

    public static let shared = ContentViewModel()

    private init() {
        BikeRentalService.shared.updateAll()
        BikeRentalService.shared.setTimer()
    }

    var blurAmount: CGFloat {
        switch mainViewContent {
        case .overlayContent:
            return 10
        default:
            return 0
        }
    }

    var brightnessAmount: Double {
        switch mainViewContent {
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
}
