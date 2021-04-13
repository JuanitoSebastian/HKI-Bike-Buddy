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
            StationCardView(rentalStation: appState.detailedBikeRentalStation!, detailed: $detailed)
                .position(x: UIScreen.main.bounds.midX, y: appState.detailedViewMidY)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                        withAnimation(.spring()) {
                            appState.detailedViewMidY = UIScreen.main.bounds.midY - 250
                            detailed = true
                        }
                    }
                }
        }
    }
}
