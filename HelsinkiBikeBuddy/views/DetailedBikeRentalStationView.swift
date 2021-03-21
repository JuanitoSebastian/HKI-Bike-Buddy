//
//  DetailedBikeRentalStationView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 20.2.2021.
//

import SwiftUI

struct DetailedBikeRentalStationView: View {

    @ObservedObject var viewModel: DetailedBikeRentalStationViewModel

    var body: some View {
        content
            .animation(.spring())
            .padding(15)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: 5, y: 5)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: -5, y: -5)
            .background(Color("AppBackground"))
    }

    var content: AnyView {
        AnyView(
            ZStack {
                VStack {

                    HStack {
                        Text(viewModel.name)
                            .font(.custom("Helvetica Neue Medium", size: 24))
                            .foregroundColor(Color("TextTitle"))

                        Spacer()

                        Button { } label: {
                            FavoriteMarker(isFavorite: true, action: {})
                        }
                    }
                    .padding([.leading, .trailing], 10)

                    HStack {
                        Text("\(viewModel.distanceInMeters()) away")
                            .foregroundColor(Color("TextMain"))
                        Spacer()
                    }
                    .padding([.bottom], 5)
                    .padding([.leading, .trailing], 10)

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
                    .padding([.leading, .trailing], 10)

                    MapView(rentalStation: viewModel.bikeRentalStation!)
                        .padding([.leading, .trailing], 10)

                }
                .padding([.top, .bottom], 10)
                .background(Color("StationCardBg"))
                .cornerRadius(10)
            }
        )
    }

}
