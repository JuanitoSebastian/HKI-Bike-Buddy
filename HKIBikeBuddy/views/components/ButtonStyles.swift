//
//  ButtonStyles.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 13.4.2021.
//

import Foundation
import SwiftUI

// MARK: - PrettyButton
struct PrettyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(Color("PrettyButtonTxt"))
                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                .background(
                    Color("PrettyButtonBg")
                        .cornerRadius(5)
                )
        }
}
// MARK: - CardButton
struct CardButton: ButtonStyle {

    // Used for scaleEffect on long-press
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

// MARK: - FavouriteMarker
struct StaticHighPriorityButtonStyle: PrimitiveButtonStyle {

    // Using highPriorityGesture makes it possible for the this button to be inside another button
    // (FavouriteMarker is inside a StationCardView which it self is a button)
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        let gesture = TapGesture()
            .onEnded { _ in configuration.trigger() }

        return configuration.label
            .highPriorityGesture(gesture)
    }
}
