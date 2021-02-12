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

    var body: some View {
        TabView(selection: $selectedTab) {
            MyBikeRentalStationsView(
                viewModel: MyBikeRentalStationsViewModel(viewContext: viewContext)
            ).padding(10)
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
            ).padding(10)
            .onTapGesture {
                selectedTab = "add"
            }
            .tabItem {
                Image(systemName: "plus")
                Text("Add Bike Rental Station")
            }
            .tag("add")
        }
    }
}
