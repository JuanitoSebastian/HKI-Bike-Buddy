//
//  MainRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 3.4.2021.
//

import SwiftUI

struct MainRentalStationsView: View {

    @EnvironmentObject var appState: AppState

    var title: String {
        switch appState.tabBarSelection {
        case .nearbyStations: return "Nearby Stations"
        case .myStations: return "My Stations"
        }
    }

    var body: some View {
        ZStack {
            NavigationView {
                TabView(selection: $appState.tabBarSelection) {

                    RentalStationsListView(rentalStations: appState.nearbyRentalStations, listType: .nearby)
                    .onTapGesture {
                        appState.tabBarSelection = .nearbyStations
                    }
                    .tabItem {
                        Image(systemName: "bicycle")
                        Text("Neaby Stations")
                    }
                    .tag(TabBarSelection.nearbyStations)

                    RentalStationsListView(rentalStations: appState.favouriteRentalStations, listType: .favourite)
                    .onTapGesture {
                        appState.tabBarSelection = .myStations
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
        }
        .onAppear(perform: {
            appState.fetchFromApi()
        })
    }
}