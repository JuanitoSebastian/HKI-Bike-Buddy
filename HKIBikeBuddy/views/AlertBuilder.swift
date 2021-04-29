//
//  AlertBuilder.swift
//  HKIBikeBuddy
//
//  Created by Juan Covarrubias on 29.4.2021.
//

import Foundation
import SwiftUI

/// Builds alerts
class AlertBuilder {

    static let shared = AlertBuilder()

    private init() {}

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

    private func notice(
        title: String,
        message: String
    ) -> Alert {
        Alert(title: Text(title), message: Text(message))
    }

    private func ationable(
        title: String,
        message: String,
        action: @escaping () -> Void,
        actionableButtonText: String
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
