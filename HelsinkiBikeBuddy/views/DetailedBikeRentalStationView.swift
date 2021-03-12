//
//  DetailedBikeRentalStationView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 20.2.2021.
//

import SwiftUI

struct DetailedBikeRentalStationView: View {

    @ObservedObject var viewModel = DetailedBikeRentalStationViewModel.shared

    var body: some View {
        VStack {
            HStack {
                Text(viewModel.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextMain"))
                Spacer()
                FavoriteMarker(isFavorite: viewModel.favorite)
                    .onTapGesture {
                        viewModel.favorite = !viewModel.favorite
                    }
            }
            HStack {
                Text(viewModel.distanceToShow)
                    .foregroundColor(Color("TextMain"))
                Spacer()

            }
            .padding([.bottom], 5)
            HStack {
                Text("\(viewModel.bikes) bikes")
                    .font(.headline)
                    .foregroundColor(Color("TextMain"))
                Spacer()
                Text("\(viewModel.spaces) spaces")
                    .font(.headline)
                    .foregroundColor(Color("TextMain"))
            }

            CapacityBar(bikesAvailable: viewModel.bikes, spacesAvailable: viewModel.spaces)
            MapView(rentalStation: viewModel.bikeRentalStation!)
                .padding([.top], 10)
            Spacer()
        }
        .padding([.leading, .trailing], 20)
        .padding([.top, .bottom], 10)
        .onTapGesture {
            withAnimation {
                ContentViewModel.shared.mainViewContent = .navigationView
            }
        }

    }
}

struct DetailedBikeRentalStationView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedBikeRentalStationView()
    }
}
