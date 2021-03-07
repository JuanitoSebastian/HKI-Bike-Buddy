//
//  OverlayContentViewController.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 5.3.2021.
//

import Foundation

class OverlayContentViewController: ObservableObject {

    public static let shared = OverlayContentViewController()

    var viewState = OverlayContentViewState.none
}

enum OverlayContentViewState {
    case detailedStation
    case settings
    case none
}
