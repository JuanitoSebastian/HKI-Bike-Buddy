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

    let appState: AppState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
