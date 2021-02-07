//
//  ContentView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.2.2021.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack {
            Button(action: { changeView() }) {
                Text("Change view")
            }
            viewToDisplay()
        }
    }

    func changeView() {
        if appState.currentViewState == .myTranstiStops {
            appState.currentViewState = .addStop
        } else {
            appState.currentViewState = .myTranstiStops
        }
    }

    func viewToDisplay() -> AnyView {
        switch appState.currentViewState {
        case .myTranstiStops:
            return AnyView(MyBikeRentalStationsView(
                            viewModel: MyBikeRentalStationsViewModel(viewContext: viewContext)
            ))
        case .addStop:
            return AnyView(CreateBikeRentalStationView(
                            viewModel: CreateBikeRentalStationViewModel(viewContext: viewContext)
            ))
        }
    }
}
