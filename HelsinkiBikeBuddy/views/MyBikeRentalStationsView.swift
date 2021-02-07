//
//  MyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct MyBikeRentalStationsView: View {

    var viewModel: MyBikeRentalStationsViewModel

    var body: some View {
        HStack {
            Text("My Rental Stations")
            ForEach(viewModel.bikeRentalStations, id: \.id) { bikeRentalStationModel in
                Text(bikeRentalStationModel.name)
            }
        }
    }
}
