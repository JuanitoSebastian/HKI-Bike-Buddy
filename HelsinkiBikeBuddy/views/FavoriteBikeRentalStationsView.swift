//
//  FavoriteBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import SwiftUI

struct FavoriteBikeRentalStationsListView: View {

    @ObservedObject var viewModel = FavoriteBikeRentalStationViewModel()

    var body: some View {
        ScrollView {
            ForEach(viewModel.favoriteBikeRentalStations, id: \.id) { bikeRentalStation in
                BikeRentalStationView(viewModel: BikeRentalStationViewModel(bikeRentalStation: bikeRentalStation))
            }
        }
    }
}
