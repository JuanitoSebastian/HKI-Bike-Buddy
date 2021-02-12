//
//  MyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct MyBikeRentalStationsView: View {

    @ObservedObject var viewModel: MyBikeRentalStationsViewModel
    @EnvironmentObject var userLocationManager: UserLocationManager

    var body: some View {
        VStack {
            Text("My Rental Stations")
            ForEach(viewModel.bikeRentalStations, id: \.name) { brStation in
                BikeRentalStationView(
                    viewModel: BikeRentalStationViewModel(
                        viewContext: viewModel.viewContext,
                        bikeRentalStation: brStation,
                        userLocationManager: userLocationManager
                    )
                )
            }
            Spacer()
        }
    }
}
