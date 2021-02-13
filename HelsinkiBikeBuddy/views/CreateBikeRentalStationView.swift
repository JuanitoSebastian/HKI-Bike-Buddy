//
//  CreateBikeRentalStationi.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct CreateBikeRentalStationView: View {

    var viewModel: CreateBikeRentalStationViewModel
    @State private var inputStationId: String = "Id"
    @State private var inputFav: Bool = true

    var body: some View {
        VStack {
            Text("Input the info")
            TextField("", text: $inputStationId)
            Toggle("Favorite", isOn: $inputFav)
            Button {
                fetchStop()
            } label: {
                Text("Create station!")
            }
            Button {
                viewModel.fetchAll()
            } label: {
                Text("Fetch all stations")
            }
        }
    }

    func fetchStop() {
        viewModel.fetchStop(stationId: inputStationId)
    }
}
