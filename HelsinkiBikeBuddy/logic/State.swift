//
//  State.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    enum ViewState {
        case myTranstiStops, addStop
    }

    @Published var currentViewState: ViewState

    init(currentViewState: ViewState) {
        self.currentViewState = currentViewState
    }
}
