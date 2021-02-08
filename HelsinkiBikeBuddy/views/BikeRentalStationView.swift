//
//  BikeRentalStationView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct BikeRentalStationView: View {

    let viewModel: BikeRentalStationViewModel

    var body: some View {
        HStack {
            Text(viewModel.name)
            Spacer()
            Text(viewModel.stationId)
            Spacer()
            Button(action: { deleteStation() }) {
                Text("Remove station")
            }
        }.onAppear(perform: {
            // Helper.log("Currently displaying: \(viewModel.name)")
        })
    }

    func deleteStation() {
        viewModel.deleteStation()
    }
}
