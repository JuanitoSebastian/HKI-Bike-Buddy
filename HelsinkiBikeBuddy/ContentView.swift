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
    @State private var selectedTab = "view"
    let bikeRentalService = BikeRentalService()

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                MyBikeRentalStationsView()
                    .onTapGesture {
                        selectedTab = "view"
                    }
                    .tabItem {
                        Image(systemName: "star")
                        Text("My Bike Rental Stations")
                    }
                    .tag("view")
                CreateBikeRentalStationView(
                    viewModel: CreateBikeRentalStationViewModel(viewContext: viewContext)
                )
                .onTapGesture {
                    selectedTab = "add"
                }
                .tabItem {
                    Image(systemName: "plus")
                    Text("Add Bike Rental Station")
                }
                .tag("add")
            }
            .navigationBarTitle("Helsinki Bike Buddy", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: { bikeRentalService.updateStations() }, label: {
                Image(systemName: "arrow.clockwise").imageScale(.large)
            }))
        }

    }
}
