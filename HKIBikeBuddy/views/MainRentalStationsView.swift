//
//  MainRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 3.4.2021.
//

import SwiftUI

struct MainRentalStationsView: View {

    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    @State var tabBarSelection: TabBarSelection = TabBarSelection.nearbyStations

    var title: String {
        switch tabBarSelection {
        case .nearbyStations: return "Nearby Stations"
        case .myStations: return "My Stations"
        }
    }

}
// MARK: - Views
extension MainRentalStationsView {
    var body: some View {
        ZStack {
            NavigationView {
                TabView(selection: $tabBarSelection) {

                    ListView(rentalStations: appState.nearbyRentalStations, listType: .nearby)
                    .onTapGesture {
                        tabBarSelection = .nearbyStations
                    }
                    .tabItem {
                        Image(systemName: "bicycle")
                        Text("Neaby Stations")
                    }
                    .tag(TabBarSelection.nearbyStations)

                    ListView(rentalStations: appState.favouriteRentalStations, listType: .favourite)
                    .onTapGesture {
                        tabBarSelection = .myStations
                    }
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("My Stations")
                    }
                    .tag(TabBarSelection.myStations)

                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {

                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                        Text(title)
                            .font(.custom("Helvetica Neue Bold", size: 20))
                            .foregroundColor(Color("TextTitle"))
                    }

                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .accentColor(Color("NavBarIconActive"))

            }
            .accentColor(Color("NavBarIconActive"))
            .sheet(item: $appState.detailedBikeRentalStation) { bikeRentalStationToDisplay in
                DetailedBikeRentalStationSheetView(
                    bikeRentalStation: bikeRentalStationToDisplay
                )
                .environmentObject(appState)
            }
            .alert(item: $appState.alert) { alert in
                AlertBuilder.shared.alert(content: alert)
            }
        }
        .onAppear(perform: onAppear)
        .onChange(of: scenePhase) { phase in scenePhaseAction(phase) }
    }

}

// MARK: - Functions
extension MainRentalStationsView {

    /// Called when MainRentalStationsView first appears. Tells AppState to subscribe to BikeRentalStationStore
    /// and asks to fetch stations from API.
    private func onAppear() {
        appState.subscribeToBikeRentalStore()
        appState.subscribeToUserLocation()
        appState.loadBikeRentalStationStore()
    }

    /// Hanldes changes in the operational state of the app.
    /// When app transition to background (inactive) appState is told to save the sotre. When the app transitions to
    /// active use the bike rental stations are reloaded from the API.
    /// - Parameter scenePhase: The ScenePhase object. Is provided by SwiftUI as EnvironmentObject.
    private func scenePhaseAction(_ scenePhase: ScenePhase) {
        if scenePhase == .inactive {
            appState.saveBikeRentalStationStore()
        }

        if scenePhase == .active {
            appState.fetchFromApi()
        }
    }
}

// MARK: - Enums
extension MainRentalStationsView {
    enum TabBarSelection: Int, Codable {
        case nearbyStations
        case myStations
    }
}

// MARK: - Preview
#if DEBUG
struct MainRentalStationsView_Previews: PreviewProvider {
    static var previews: some View {
        MainRentalStationsView()
            .environmentObject(AppState.shared)
    }
}
#endif
