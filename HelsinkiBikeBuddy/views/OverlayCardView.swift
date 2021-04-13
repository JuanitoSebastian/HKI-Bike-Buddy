//
//  OverlayCardView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 9.4.2021.
//

import SwiftUI

struct OverlayCardView: View {
    @EnvironmentObject var appState: AppState
    @State var detailed: Bool = false

    var body: some View {
        if appState.detailedBikeRentalStation == nil {
            EmptyView()
        } else {
            StationCardView(rentalStation: appState.detailedBikeRentalStation!, detailed: .constant(true))
                .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        }
    }
}
