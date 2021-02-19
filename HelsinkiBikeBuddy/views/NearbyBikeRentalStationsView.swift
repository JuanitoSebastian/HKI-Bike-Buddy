//
//  NearbyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import SwiftUI

struct NearbyBikeRentalStationsListView: View {

    @ObservedObject var viewModel = NeabyBikeRentalStationsViewModel.shared

    var body: some View {
        VStack {
            ScrollView {
                ForEach(0..<viewModel.nearbyBikeRentalStations.count, id: \.self) {
                    BikeRentalStationView(viewModel: BikeRentalStationViewModel(bikeRentalStation: viewModel.nearbyBikeRentalStations[$0]))
                    Divider()
                }
            }
            Spacer()
        }
    }
}
