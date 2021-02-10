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
    let persistenceController = PersistenceController.shared
    let appState = AppState(currentViewState: AppState.ViewState.myTranstiStops)
    let userLocationManager = UserLocationManager(CLLocationManager())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .environmentObject(userLocationManager)
        }
    }
}
