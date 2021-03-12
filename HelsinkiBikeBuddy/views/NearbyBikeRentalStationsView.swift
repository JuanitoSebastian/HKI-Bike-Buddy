//
//  NearbyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 18.2.2021.
//

import SwiftUI
// TODO: Pull to refrseh!
struct NearbyBikeRentalStationsListView: View {

    @ObservedObject var viewModel = NearbyBikeRentalStationsListViewModel.shared
    var body: some View {
        VStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("mainBgImg")
                .resizable()
                .scaledToFill()
                .background(Color("AppBackground"))
        )

    }

    var content: AnyView {
        switch viewModel.state {
        case .nearbyStations:
            return AnyView(
                VStack {
                    ScrollView {
                        Text("Nearby Stations")
                            .font(.custom("Helvetica Neue Condensed Bold", size: 55))
                            .foregroundColor(Color("TextTitle"))
                            .padding([.top, .bottom], 10)
                        ForEach(viewModel.nearbyBikeRentalStations, id: \.id) { stationNearby in
                            BikeRentalStationView(viewModel: BikeRentalStationViewModel(bikeRentalStation: stationNearby))
                        }
                    }
                    Spacer()
                }
            )
        default:
            return AnyView(
                VStack {
                    Spacer()
                    Text("No bike rental stations nearby... ☹️")
                    Spacer()
                }
            )
        }
    }
}
