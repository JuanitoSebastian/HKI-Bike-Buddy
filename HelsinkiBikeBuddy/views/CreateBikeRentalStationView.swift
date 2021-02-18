//
//  CreateBikeRentalStationi.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI

struct CreateBikeRentalStationView: View {

    var viewModel: CreateBikeRentalStationViewModel

    var body: some View {
        VStack {
            Button {
                viewModel.fetchNearby()
            } label: {
                Text("Fetch stations!")
            }
        }
    }
}
