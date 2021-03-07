//
//  FavoriteBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import SwiftUI

struct FavoriteBikeRentalStationsListView: View {

    @ObservedObject var viewModel = FavoriteBikeRentalStationViewModel.shared

    var body: some View {
        content
    }

    var content: AnyView {
        switch viewModel.state {

        case FavoriteBikeRentalStationsState.favoriteBikeRentalStations:
            return AnyView(
                VStack {
                    ScrollView {
                        Text("My Stations")
                            .font(.custom("Helvetica Neue Condensed Bold", size: 55))
                            .foregroundColor(Color("TextTitle"))
                            .padding([.top, .bottom], 10)

                        ForEach(viewModel.favoriteBikeRentalStations, id: \.id) { bikeRentalStation in
                            BikeRentalStationView(viewModel: BikeRentalStationViewModel(bikeRentalStation: bikeRentalStation))
                        }
                    }
                    Spacer()
                }
                .background(
                    Image("mainBgImg")
                        .resizable()
                        .scaledToFill()
                        .background(Color("AppBackground"))

                )
            )

        case FavoriteBikeRentalStationsState.noFavorites:
            return AnyView(
                VStack {
                    Spacer()
                    Text("🚴‍♀️")
                        .padding(5)
                    Text("Nothing here yet...")
                        .font(.caption)
                        .foregroundColor(Color("TextMain"))
                    Text("Start by marking a station as your favourite.")
                        .font(.caption)
                        .foregroundColor(Color("TextMain"))
                    Spacer()
                }
            )
        }
    }
}
