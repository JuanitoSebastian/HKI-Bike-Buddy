//
//  HelsinkiBikeBuddyApp.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.2.2021.
//

import SwiftUI

@main
struct HelsinkiBikeBuddyApp: App {
    let persistenceController = PersistenceController.shared
    let appState = AppState(currentViewState: AppState.ViewState.myTranstiStops)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
        }
    }
}
