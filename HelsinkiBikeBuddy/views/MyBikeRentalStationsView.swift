//
//  MyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct MyBikeRentalStationsView: View {

    @ObservedObject var viewModel: MyBikeRentalStationsViewModel

    var body: some View {
        VStack {
            Text("My Rental Stations")
            ForEach(viewModel.bikeRentalStations, id: \.name) { brStation in
                BikeRentalStationView(viewModel: BikeRentalStationViewModel(
                                        viewContext: viewModel.viewContext,
                                        bikeRentalStation: brStation)
                )
            }
        }.onAppear(perform: {
            Helper.log("Inside view:")
            for station in viewModel.bikeRentalStations {
                Helper.log(station.name)
            }
        })
    }
}
