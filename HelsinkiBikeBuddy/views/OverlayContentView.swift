//
//  OverlayContentView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 5.3.2021.
//

import SwiftUI

struct OverlayContentView: View {

    @ObservedObject var viewModel = OverlayContentViewController.shared

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
                .shadow(radius: 5)
            content
        }
        .padding(40)
    }

    var content: AnyView {
        switch viewModel.viewState {
        case .detailedStation:
            return AnyView(DetailedBikeRentalStationView())
        case .settings:
            return AnyView(Text("Settings"))
        case .none:
            return AnyView(EmptyView())
        }
    }
}
