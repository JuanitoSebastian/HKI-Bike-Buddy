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
    @ObservedObject var userLocationManager = UserLocationManager.shared

    var body: some View {
        contentToDisplay

    }

    var contentToDisplay: AnyView {
        if userLocationManager.locationAuthorization == .denied {
            return AnyView(PermissionsPromptView())
        }

        if bikeRentalService.apiState == .error {
            return error
        }

        switch viewModel.appState {
        case .loading:
            return loading
        default:
            return main
        }
    }

    // MARK: - Main Appplication view
    var main: AnyView {
        return AnyView(
            ZStack {
                NavigationView {
                    TabView(selection: $viewModel.navigationSelection) {
                        BikeRentalStationsListView(
                            viewModel: BikeRentalStationsListViewModel(
                                publisher: BikeRentalStationStorage.shared.stationsNearby.eraseToAnyPublisher()
                            )
                        )
                            .onTapGesture {
                                viewModel.navigationSelection = MainViewNavigation.nearbyStations
                            }
                            .tabItem {
                                Image(systemName: "bicycle")
                                Text("Neaby Stations")
                            }
                            .tag(MainViewNavigation.nearbyStations)

                        BikeRentalStationsListView(
                            viewModel: BikeRentalStationsListViewModel(
                                publisher: BikeRentalStationStorage.shared.stationsFavorite.eraseToAnyPublisher()
                            )
                        )
                            .onTapGesture {
                                viewModel.navigationSelection = MainViewNavigation.myStations
                            }
                            .tabItem {
                                Image(systemName: "heart.fill")
                                Text("My Stations")
                            }
                            .tag(MainViewNavigation.myStations)

                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                            Text(viewModel.title)
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
                    .blur(radius: viewModel.blurAmount)
                    .brightness(viewModel.brightnessAmount)

                }
                .accentColor(Color("NavBarIconActive"))
                if case MainViewContent.overlayContent = viewModel.appState {
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
