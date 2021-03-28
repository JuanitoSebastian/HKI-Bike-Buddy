//
//  BikeRentalStationView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI
import CoreData

struct BikeRentalStationCardView: View {

    @ObservedObject var viewModel: BikeRentalStationViewModel

    init(viewModel: BikeRentalStationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .animation(.spring())
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 15)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: 5, y: 5)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: -5, y: -5)
    }

    var stationInfoColor: Color {
        Color(Color.RGBColorSpace.sRGB, white: 0.5, opacity: 0.1)
    }

    var content: AnyView {
        switch viewModel.state {

        // MARK: - - STATION AVAILABLE
        case BikeRentalStationViewState.normal:
            return AnyView(
                ZStack {
                    VStack {
                        HStack {
                            Text(viewModel.name)
                                .font(.custom("Helvetica Neue Medium", size: 24))
                                .foregroundColor(Color("TextTitle"))
                            Spacer()

                            FavoriteMarker(isActive: viewModel.favoriteStatus, action: {
                                withAnimation {
                                    viewModel.toggleFavourite()
                                }
                            })

                        }
                        HStack {
                            Text("\(viewModel.distanceInMeters()) away")
                                .foregroundColor(Color("TextMain"))
                            Spacer()

                        }
                        .padding([.bottom], 5)
                        VStack {
                            CapacityBar(leftValue: viewModel.bikes, rightValue: viewModel.spaces)
                                .shadow(color: Color("StationCardShadow"), radius: 3, x: 0, y: 3)
                                .padding([.top], 2)
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
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, stationInfoColor]),
                                startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(10)

                    }
                    .padding([.leading, .trailing], 15)
                    .padding([.top], 5)
                    .padding([.bottom], 10)
                }
                .background(Color("StationCardBg"))
                .cornerRadius(10)
                .onTapGesture(count: 2) {
                    withAnimation {
                        viewModel.toggleFavourite()
                    }
                }
            )

        // MARK: - - STATION UNAVAILABLE
        case .unavailable:
            return AnyView(
                ZStack {
                    VStack {
                        HStack {
                            Text(viewModel.name)
                                .font(.custom("Helvetica Neue Medium", size: 24))
                                .foregroundColor(Color("TextTitle"))
                            Spacer()
                            FavoriteMarker(isActive: viewModel.favoriteStatus, action: { viewModel.toggleFavourite() })
                        }
                        HStack {
                            Text("\(viewModel.distanceInMeters()) away")
                                .foregroundColor(Color("TextMain"))
                            Spacer()

                        }
                        .padding([.bottom], 5)
                        VStack {
                            HStack {
                                Spacer()
                                Text("Station is not in use")
                                    .font(.headline)
                                    .foregroundColor(Color("TextMain"))
                                Spacer()
                            }
                            .padding(10)
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
                .onTapGesture(count: 2) {
                    withAnimation {
                        viewModel.toggleFavourite()
                    }
                }

            )
        }
    }

}

struct StaticHighPriorityButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        let gesture = TapGesture()
            .onEnded { _ in configuration.trigger() }

        return configuration.label
            .highPriorityGesture(gesture)
    }
}
