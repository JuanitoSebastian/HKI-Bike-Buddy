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
            ZStack {
                VStack {
                    HStack {
                        Text(viewModel.name)
                            .font(.custom("Helvetica Neue Condensed Bold", size: 35))
                            .foregroundColor(Color("TextTitle"))
                        Spacer()
                        FavoriteMarker(isFavorite: viewModel.favorite)
                            .onTapGesture {

                            }
                    }
                    HStack {
                        Text("\(viewModel.distanceInMeters()) away 🚶")
                            .foregroundColor(Color("TextMain"))
                        Spacer()

                    }
                    .padding([.bottom], 5)
                    VStack {
                        CapacityBar(bikesAvailable: viewModel.bikes, spacesAvailable: viewModel.spaces)
                            .shadow(color: Color("StationCardShadow"), radius: 3, x: 0, y: 3)
                        HStack {
                            Text("\(viewModel.bikes) bikes")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                            Spacer()
                            Text("\(viewModel.spaces) spaces")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                        }
                        .padding([.leading, .trailing, .bottom], 10)
                    }
                    .background(Color("StationInfoBg"))
                    .cornerRadius(10)

                }
                .padding([.leading, .trailing], 15)
                .padding([.top], 5)
                .padding([.bottom], 10)
            }
            .background(Color("StationCardBg"))
            .cornerRadius(10)

            ZStack {
                MapView(rentalStation: viewModel.bikeRentalStation!)
                    .padding([.leading, .trailing], 15)
                    .padding([.top, .bottom], 10)
            }
            .background(Color("StationCardBg"))
            .cornerRadius(10)

            ZStack {
                PrettyButton(textToDisplay: "←", perform: { withAnimation { ContentViewModel.shared.mainViewContent = .navigationView }})
                    .padding([.leading, .trailing], 15)
                    .padding([.top, .bottom], 10)
            }
            .background(Color("StationCardBg"))
            .cornerRadius(10)
        }
        .padding([.leading, .trailing], 15)
        .padding([.top, .bottom], 40)
        .shadow(color: Color("StationCardShadow"), radius: 3, x: 0, y: 3)

    }
}

struct DetailedBikeRentalStationView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedBikeRentalStationView()
    }
}
