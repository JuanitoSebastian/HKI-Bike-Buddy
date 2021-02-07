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
            ForEach(viewModel.bikeRentalStations, id: \.id) { bikeRentalStationModel in
                BikeRentalStationView(viewModel: BikeRentalStationViewModel(viewContext: viewModel.viewContext, bikeRentalStation: bikeRentalStationModel))
            }
        }
    }
}
