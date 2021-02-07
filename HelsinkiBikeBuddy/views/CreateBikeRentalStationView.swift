//
//  CreateBikeRentalStationi.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct CreateBikeRentalStationView: View {

    var viewModel: CreateBikeRentalStationViewModel
    @State private var inputName: String = ""
    @State private var inputStationId: String = ""
    @State private var inputLat: String = ""
    @State private var inputLon: String = ""
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Text("Input the info")
            TextField("", text: $inputName)
            TextField("", text: $inputStationId)
            TextField("", text: $inputLat)
            TextField("", text: $inputLon)
            Button(action: { createStop() } ) {
                Text("Add station")
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
