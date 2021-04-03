//
//  NearbyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import SwiftUI
import Combine

struct BikeRentalStationsListView: View {

    @ObservedObject var viewModel: BikeRentalStationsListViewModel

    var body: some View {
        VStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("AppBackground")
        )

    }

    var content: AnyView {
        switch viewModel.state {
        case .stationsLoaded:
            return AnyView(
                VStack {
                    ScrollView {
                        ForEach(viewModel.rentalStations, id: \.id) { bikeRentalStation in
                            NavigationLink(
                                destination: DetailedBikeRentalStationView(
                                    viewModel: DetailedBikeRentalStationViewModel(
                                        bikeRentalStation: bikeRentalStation)
                                )
                            ) {
                                BikeRentalStationCardView(
                                    viewModel: BikeRentalStationCardViewModel(bikeRentalStation: bikeRentalStation)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())

                        }
                    }
                    Spacer()
                }
            )
        case .empty:
            return AnyView(
                VStack {
                    Spacer()
                    Text(viewModel.listEmptyText)
                        .foregroundColor(Color("TextMain"))
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            )

        case .loading:
            return AnyView(
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            )
        }
    }
}
