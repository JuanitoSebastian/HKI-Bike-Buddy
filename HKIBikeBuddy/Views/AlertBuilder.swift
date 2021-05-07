//
//  AlertBuilder.swift
//  HKIBikeBuddy
//
//  Created by Juan Covarrubias on 29.4.2021.
//

import Foundation
import SwiftUI

/// A class for building alerts 🚨
class AlertBuilder {

    static let shared = AlertBuilder()

    private init() {}

    /// Create an alert based on AlertContent
    /// - Parameter content: Content of the alert
    /// - Returns a displayable Alert object
    func alert(
        content: AlertContent
    ) -> Alert {
        switch content.type {
        case .notice:
            return notice(title: content.title, message: content.message)
        case .actionable:
            return ationable(
                title: content.title,
                message: content.message,
                action: content.action,
                actionableButtonText: content.actionableButtonText
            )
        }
    }

    /// Creates an alert with an ok button (no action)
    private func notice(
        title: LocalizedStringKey,
        message: LocalizedStringKey
    ) -> Alert {
        Alert(title: Text(title), message: Text(message))
    }

    /// Creates an actionable alert
    private func ationable(
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        action: @escaping () -> Void,
        actionableButtonText: LocalizedStringKey
    ) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(
                Text(actionableButtonText),
                action: action
            )
        )
    }
}
