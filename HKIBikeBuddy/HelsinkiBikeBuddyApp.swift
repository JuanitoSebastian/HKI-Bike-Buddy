//
//  HelsinkiBikeBuddyApp.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.2.2021.
//

import SwiftUI
import CoreLocation

@main
struct HelsinkiBikeBuddyApp: App {

    let appState: AppState

    init() {
        self.appState = AppState.shared
        self.appState.subscribeToUserLocationServiceAuthorization()
    }

    /// Passing appState as environmentObject here at the root of the app
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
