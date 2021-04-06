//
//  RentalStationsListView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 3.4.2021.
//

import SwiftUI

struct RentalStationsListView: View {

    @EnvironmentObject var appState: AppState
    let rentalStations: [RentalStation]
    let listType: BikeRentalStationListType

    private var listState: ListState {
        if rentalStations.isEmpty {
            if listType == .nearby && appState.apiState == .loading {
                return .loading
            }
            return .empty
        }

        return .stationsLoaded
    }

    private var listEmptyText: String {
        switch listType {
        case .favourite:
            return "Favourite a Bike Rental Station to add it here 💗"
        case .nearby:
            return "No stations were found nearby 🤔\n" +
            "Try increasing the nearby station radius from settings"
        }
    }

    // MARK: - Views
    var body: some View {
        VStack {
            contentToDisplay
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("AppBackground")
        )
    }

    private var contentToDisplay: AnyView {
        switch listState {
        case .stationsLoaded: return stationsLoadedView
        case .loading: return loadingView
        case .empty: return emptyView
        }
    }

    private var stationsLoadedView: AnyView {
        AnyView(
            VStack {
                ScrollView {
                    ForEach(rentalStations, id: \.id) { rentalStation in
                        RentalStationCardView(rentalStation: rentalStation)
                    }
                }
            }
        )
    }

    private var loadingView: AnyView {
        AnyView(
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        )
    }

    private var emptyView: AnyView {
        AnyView(
            VStack {
                Spacer()
                Text(listEmptyText)
                    .foregroundColor(Color("TextMain"))
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        )
    }

    // MARK: - Enums
    private enum ListState {
        case stationsLoaded
        case empty
        case loading
    }

    public enum BikeRentalStationListType {
        case favourite
        case nearby
    }

}
