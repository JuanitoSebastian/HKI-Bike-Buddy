//
//  MyBikeRentalStationsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct MyBikeRentalStationsView: View {

    @StateObject var viewModel = MyBikeRentalStationsViewModel()
    @State private var favToggle = false
    @State private var selected = 0

    var body: some View {
        VStack {
            Picker(selection: $selected, label: Text(""), content: {
                Text("My Stations").tag(0)
                    .onTapGesture {
                        selected = 0
                    }
                Text("All Stations").tag(1)
                    .onTapGesture {
                        selected = 1
                    }
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding([.top, .leading, .trailing], 5)
            stationList
            Spacer()
        }
    }

    var stationList: AnyView {
        switch selected {
        case 0:
            return AnyView(
                ScrollView {
                    ForEach(viewModel.favoriteStations, id: \.id) { bikeRentalStation in
                        BikeRentalStationView(viewModel: BikeRentalStationViewModel(stationId: bikeRentalStation.stationId))
                    }
                })
        default:
            return AnyView(
                ScrollView {
                    ForEach(0...10, id: \.self) {
                        BikeRentalStationView(viewModel: BikeRentalStationViewModel(stationId: viewModel.bikeRentalStations[$0].stationId))
                    }
                })
        }
    }
}
