//
//  CreateBikeRentalStationi.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct CreateBikeRentalStationView: View {

    var viewModel: CreateBikeRentalStationViewModel
    @State private var inputName: String = "Name"
    @State private var inputStationId: String = "Id"
    @State private var inputLat: String = "Lat"
    @State private var inputLon: String = "Lon"

    var body: some View {
        VStack {
            Text("Input the info")
            TextField("", text: $inputName)
            TextField("", text: $inputStationId)
            TextField("", text: $inputLat)
            TextField("", text: $inputLon)
            Button {
                createStop()
            } label: {
                Text("Create station!")
            }
        }
    }

    func createStop() {
        viewModel.createBikeRentalStop(
            name: inputName,
            stationId: inputStationId,
            lat: inputLat,
            lon: inputLon
        )
    }
}
