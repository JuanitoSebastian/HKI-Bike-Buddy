//
//  ContentView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 6.2.2021.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @ObservedObject var viewModel = ContentViewModel.shared
    @ObservedObject var bikeRentalService = BikeRentalService.shared

    var body: some View {
        contentToDisplay

    }

    var contentToDisplay: AnyView {
        if bikeRentalService.apiState == .error {
            return error
        }

        switch viewModel.mainViewContent {
        case .loading:
            return loading
        default:
            return main
        }
    }

    // MARK: - Main Appplication view
    var main: AnyView {
        AnyView(
            ZStack {
                TabView(selection: $viewModel.navigationSelection) {
                    NearbyBikeRentalStationsListView()
                        .onTapGesture {
                            viewModel.navigationSelection = MainViewNavigation.nearbyStations
                        }
                        .tabItem {
                            Image(systemName: "bicycle")
                            Text("Neaby Stations")
                        }
                        .tag(MainViewNavigation.nearbyStations)

                    FavoriteBikeRentalStationsListView()
                        .onTapGesture {
                            viewModel.navigationSelection = MainViewNavigation.myStations
                        }
                        .tabItem {
                            Image(systemName: "heart.fill")
                            Text("My Stations")
                        }
                        .tag(MainViewNavigation.myStations)

                    SettingsView()
                        .onTapGesture {
                            viewModel.navigationSelection = MainViewNavigation.settings
                        }
                        .tabItem {
                            Image(systemName: "eye")
                            Text("Settings")
                        }
                        .tag(MainViewNavigation.settings)
                }
                .background(Color("NavBarBg"))
                .accentColor(Color("NavBarIconActive"))
                .blur(radius: viewModel.blurAmount)
                .brightness(viewModel.brightnessAmount)

                if viewModel.mainViewContent == MainViewContent.overlayContent {
                    OverlayContentView()
                        .transition(.opacity)
                        .animation(.easeIn)
                }

            }
        )
    }

    // MARK: - Loading spinner
    var loading: AnyView {
        AnyView(
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        )
    }

    // MARK: - Error state

    var error: AnyView {
        AnyView(
            VStack {
                Spacer()
                Text("No Internet connection 😬")
                Spacer()
            }
        )
    }
}
