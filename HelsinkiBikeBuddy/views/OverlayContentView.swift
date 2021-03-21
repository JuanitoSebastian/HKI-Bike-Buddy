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
        content
    }

    var content: AnyView {
        switch viewModel.viewState {
        case .detailedStation:
            return AnyView(EmptyView())
        case .settings:
            return AnyView(Text("Settings"))
        case .none:
            return AnyView(EmptyView())
        }
    }
}
