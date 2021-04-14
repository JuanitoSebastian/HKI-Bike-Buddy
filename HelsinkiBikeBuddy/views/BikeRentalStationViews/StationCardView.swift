//
//  RentalStationCardView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 3.4.2021.
//

import SwiftUI
import CoreLocation

// MARK: - Properties
struct StationCardView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject var bikeRentalStation: BikeRentalStation
    @State var toggleTriggered: Bool = false
    @State var longPress = false

    private var stationInfoColor: Color {
        Color(Color.RGBColorSpace.sRGB, white: 0.5, opacity: 0.1)
    }

    private var distanceString: String {
        guard let userLocation = appState.userLocation else {
            return "-"
        }

        var distanceDouble = Int(
            Helper.roundToNearest(
                bikeRentalStation.location.distance(from: userLocation), toNearest: 20
            )
        )

        if distanceDouble >= 1000 {
            distanceDouble /= 1000
            return "\(String(distanceDouble)) km"
        }

        return "\(String(distanceDouble)) m"
    }

}

// MARK: - Views
extension StationCardView {

    var body: some View {
        Button {
            longPress = false
        } label: {
            Card {
                stationCardContent
            }
        }
        .buttonStyle(CardButton())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.1)
                .onEnded { _ in
                    Haptics.shared.feedback(intensity: .hard)
                    longPressAction()
                }
        )
        .onTapGesture(count: 2) {
            toggleFavourite()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
    }

    // Contents for when station is in use
    private var stationCardContent: AnyView {
        AnyView(
            VStack {
                BikeRentalStationViewBuilder.shared.nameAndFavouriteStatusComponent(
                    name: bikeRentalStation.name,
                    favouriteStatus: $bikeRentalStation.favourite,
                    favouriteAction: toggleFavourite
                )

                BikeRentalStationViewBuilder.shared.distanceFromUserComponent(
                    distanceFromUserString: distanceString
                )
                    .padding([.bottom], 5)

                BikeRentalStationViewBuilder.shared.bikeAmountsComponent(
                    bikes: bikeRentalStation.bikes,
                    spaces: bikeRentalStation.spaces,
                    state: bikeRentalStation.state
                )
            }
        )
    }
}
// MARK: - Functions
extension StationCardView {
    private func toggleFavourite() {
        if toggleTriggered { return }
        toggleTriggered = true
        Haptics.shared.feedback(intensity: .medium, delay: 750)

        if bikeRentalStation.favourite {
            bikeRentalStation.favourite.toggle()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                withAnimation(.spring()) {
                    appState.unFavouriteRentalStation(bikeRentalStation)
                    self.toggleTriggered = false
                }
            }
        } else {
            bikeRentalStation.favourite.toggle()
            withAnimation(.spring()) {
                appState.favouriteRentalStation(bikeRentalStation)
                toggleTriggered = false
            }
        }
    }

    private func longPressAction() {
        withAnimation(.spring()) {
            appState.setDetailedViewStatation(bikeRentalStation)
            appState.toggleDetailedView()
        }
    }

}

// MARK: - Enums
extension StationCardView {
    public enum RentalStationState {
        case inUse
        case notInUse
    }
}
