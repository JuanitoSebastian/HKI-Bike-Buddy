//
//  MyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct BikeRentalStationsView: View {

    @StateObject var viewModel = BikeRentalStationsViewModel()

    var body: some View {
        VStack {
            Picker(selection: $viewModel.pickerSelection, label: Text(""), content: {
                Text("My Stations").tag(0)
                    .onTapGesture {
                        viewModel.pickerSelection = 0
                    }
                Text("All Stations").tag(1)
                    .onTapGesture {
                        viewModel.pickerSelection = 1
                    }
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding([.top, .leading, .trailing], 5)
            stationList
            Spacer()
        }
    }

    var stationList: AnyView {
        switch viewModel.pickerSelection {
        case 0:
            return AnyView(
                FavoriteBikeRentalStationsListView()
            )
        default:
            return AnyView(
                NearbyBikeRentalStationsListView()
            )
        }
    }
}
