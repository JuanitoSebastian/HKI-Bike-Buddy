//
//  ButtonStyles.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 13.4.2021.
//

import Foundation
import SwiftUI

// MARK: - CardButton
struct CardButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
