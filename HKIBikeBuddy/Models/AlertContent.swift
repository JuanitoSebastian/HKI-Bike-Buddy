//
//  Notification.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 20.4.2021.
//

import Foundation
import SwiftUI

/// Content to be dispalyed in an alert 🚨
struct AlertContent: Identifiable {

    let id = UUID()
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let type: AlertType
    let action: () -> Void
    let actionableButtonText: LocalizedStringKey

    init(
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        type: AlertType,
        action: @escaping () -> Void = {},
        actionableButtonText: LocalizedStringKey = LocalizedStringKey("")
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
            title: LocalizedStringKey("alertTitleApiError"),
            message: LocalizedStringKey("alertMessageApiError"),
            type: .actionable,
            action: AppState.shared.fetchFromApi,
            actionableButtonText: LocalizedStringKey("alertButtonTryAgain")
        )
    }

    static var noInternet: AlertContent {
        AlertContent(
            title: LocalizedStringKey("alertTitleNetworkError"),
            message: LocalizedStringKey("alertMessageNetworkError"),
            type: .actionable,
            action: AppState.shared.fetchFromApi,
            actionableButtonText: LocalizedStringKey("alertButtonTryAgain")
        )
    }

    static var noLocation: AlertContent {
        AlertContent(
            title: LocalizedStringKey("alertTitleLocationError"),
            message: LocalizedStringKey("alertMessageLocationError"),
            type: .notice
        )
    }

    static var failedToLoadStore: AlertContent {
        AlertContent(
            title: LocalizedStringKey("alertTitleStoreLoadError"),
            message: LocalizedStringKey("alertMessageStoreLoadError"),
            type: .actionable,
            action: { AppState.shared.loadBikeRentalStationStore() },
            actionableButtonText: LocalizedStringKey("alertButtonTryAgain")
        )
    }

    static var failedToSaveStore: AlertContent {
        AlertContent(
            title: LocalizedStringKey("alertTitleStoreSaveError"),
            message: LocalizedStringKey("alertMessageStoreSaveError"),
            type: .actionable,
            action: { AppState.shared.saveBikeRentalStationStore() },
            actionableButtonText: LocalizedStringKey("alertButtonTryAgain")
        )
    }

}
