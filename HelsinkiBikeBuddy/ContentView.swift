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

    var body: some View {
        NavigationView {
            TabView(selection: $viewModel.viewSelection) {
                NearbyBikeRentalStationsListView()
                    .onTapGesture {
                        viewModel.viewSelection = MainViewContent.nearbyStations
                    }
                    .tabItem {
                        Image(systemName: "bicycle")
                        Text("Neaby Stations")
                    }
                    .tag(MainViewContent.nearbyStations)

                FavoriteBikeRentalStationsListView()
                    .onTapGesture {
                        viewModel.viewSelection = MainViewContent.myStations
                    }
                    .tabItem {
                        Image(systemName: "heart")
                        Text("My Stations")
                    }
                    .tag(MainViewContent.myStations)

                CreateBikeRentalStationView(
                    viewModel: CreateBikeRentalStationViewModel()
                )
                .onTapGesture {
                    viewModel.viewSelection = MainViewContent.map
                }
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(MainViewContent.map)
            }
            .navigationBarTitle(Text(viewModel.navBarTitle), displayMode: .large)
            .navigationBarItems(trailing: Button(action: { BikeRentalService.shared.fetchNearbyStations() }, label: {
                Image(systemName: "arrow.clockwise").imageScale(.large)
            }))
        }

    }
}
