//
//  ContentView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.2.2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            mainContentToDisplay
        }
    }

    var mainContentToDisplay: AnyView {
        switch appState.mainView {
        case .rentalStations:
            return AnyView(MainRentalStationsView())
        case .locationPrompt:
            return AnyView(PermissionsPromptView())
        }
    }

}
