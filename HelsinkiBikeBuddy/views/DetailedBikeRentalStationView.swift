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
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
                .shadow(radius: 5)
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
                .padding([.leading, .trailing], 20)
                HStack {
                    Text(viewModel.distanceToShow)
                        .foregroundColor(Color("TextMain"))
                    Spacer()

                }
                .padding([.leading, .trailing], 20)
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
                .padding([.leading, .trailing], 20)
                CapacityBar(bikesAvailable: viewModel.bikes, spacesAvailable: viewModel.spaces)
                MapView(rentalStation: viewModel.bikeRentalStation!)
                Spacer()
            }
            .padding([.top, .bottom], 10)
        }
        .padding(40)
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
