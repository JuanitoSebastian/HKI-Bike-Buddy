//
//  NearbyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import SwiftUI
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
                        ForEach(viewModel.bikeRentalStations, id: \.id) { bikeRentalStation in
                            BikeRentalStationView(
                                viewModel: BikeRentalStationViewModel(bikeRentalStation: bikeRentalStation
                                )
                            )
                        }
                    }
                    Spacer()
                }
            )
        default:
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
