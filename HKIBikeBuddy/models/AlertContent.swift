//
//  Notification.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 20.4.2021.
//

import Foundation

/// A model for the content to be dispalyed in an alert 🚨
struct AlertContent: Identifiable {

    let id = UUID()
    let title: String
    let message: String
    let type: AlertType
    let action: () -> Void
    let actionableButtonText: String

    init(
        title: String,
        message: String,
        type: AlertType,
        action: @escaping () -> Void = {},
        actionableButtonText: String = ""
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.action = action
        self.actionableButtonText = actionableButtonText
    }

}

// MARK: - Enums
extension AlertContent {

    enum AlertType {
        case notice
        case actionable
    }

}

// MARK: - Computed properties
extension AlertContent {

    static var fetchError: AlertContent {
        AlertContent(
            title: "Network Error",
            message: "Failed to fetch stations",
            type: .actionable,
            action: AppState.shared.fetchFromApi,
            actionableButtonText: "Try again"
        )
    }

    static var noInternet: AlertContent {
        AlertContent(
            title: "Network Error",
            message: "No internet connection",
            type: .actionable,
            action: AppState.shared.fetchFromApi,
            actionableButtonText: "Try again"
        )
    }

    static var noLocation: AlertContent {
        AlertContent(
            title: "Current Location Not Available",
            message: "Your current location could not be determined",
            type: .notice
        )
    }

    static var failedToLoadStore: AlertContent {
        AlertContent(
            title: "Could Not Load Favourite Stations",
            message: "Failed to load favourite stations from memory",
            type: .actionable,
            action: { AppState.shared.loadBikeRentalStationStore() },
            actionableButtonText: "Try again"
        )
    }

    static var failedToSaveStore: AlertContent {
        AlertContent(
            title: "Could Not Save Favourite Stations",
            message: "Failed to save favourite stations to memory",
            type: .actionable,
            action: { AppState.shared.saveBikeRentalStationStore() },
            actionableButtonText: "Try again"
        )
    }

}
