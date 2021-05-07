//
//  ContentView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.2.2021.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var appState: AppState

    /// If the app has access to location services the main view is shown
    /// otherwise the permission prompt is shown
    var body: some View {
        switch appState.mainView {
        case .rentalStations:
            return AnyView(MainRentalStationsView())
        case .locationPrompt:
            return AnyView(PermissionsPromptView())
        }
    }
}
