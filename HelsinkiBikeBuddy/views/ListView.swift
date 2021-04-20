//
//  RentalStationsListView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 3.4.2021.
//

import SwiftUI

struct ListView: View {

    @EnvironmentObject var appState: AppState
    let rentalStations: [BikeRentalStation]
    let listType: BikeRentalStationListType
    let layout = [GridItem(.flexible(maximum: .infinity))]

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
            return "Nothing here yet...\n" +
                "Start by marking a station as your favourite 💖"
        case .nearby:
            return "No stations nearby 😔\n" +
                "Try increasing the nearby radius from settings"
        }
    }

}

    // MARK: - Views
extension ListView {

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
                    PullToRefreshScrollView(onRelease: { appState.fetchFromApi() }) {
                        LazyVGrid(columns: layout) {
                            ForEach(rentalStations, id: \.id) { rentalStation in
                                StationCardView(bikeRentalStation: rentalStation)
                                    .highPriorityGesture(
                                        TapGesture(count: 2)
                                            .onEnded { _ in

                                            }
                                    )
                            }
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
                    .font(.callout)
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

// MARK: - Preview
#if DEBUG
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(rentalStations: BikeRentalStation.placeholderStations, listType: .nearby)
            .environmentObject(AppState.shared)
    }
}
#endif
