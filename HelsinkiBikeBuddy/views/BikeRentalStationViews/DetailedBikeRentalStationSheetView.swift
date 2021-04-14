//
//  DetailedBikeRentalStationSheetView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.4.2021.
//

import SwiftUI

struct DetailedBikeRentalStationSheetView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject var bikeRentalStation: BikeRentalStation
    @State var toggleTriggered: Bool = false

    var body: some View {
        content
            .padding(.top, 15)
    }

    var content: AnyView {
        if appState.detailedBikeRentalStation == nil {
            return AnyView(EmptyView())
        }
        return AnyView(

            ZStack(alignment: .top) {
                VStack {
                    HStack {
                        Text(bikeRentalStation.name)
                            .font(.custom("Helvetica Neue Medium", size: 38))
                            .foregroundColor(Color("TextTitle"))
                        Spacer()
                    }
                    .padding(.horizontal, 15)

                    BikeRentalStationViewBuilder.shared.distanceFromUserComponent(
                        distanceFromUserString: distanceString
                    )
                    .padding(.horizontal, 15)

                    ZStack(alignment: .bottom) {

                        MapView(rentalStation: bikeRentalStation)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                                    startPoint: UnitPoint(x: 0.5, y: 0.7),
                                    endPoint: .bottom
                                )
                            )

                        BikeRentalStationViewBuilder.shared.bikeAmountsComponent(
                            bikes: bikeRentalStation.bikes,
                            spaces: bikeRentalStation.spaces,
                            state: bikeRentalStation.state
                        )
                        .padding([.horizontal], 15)
                        .padding(.bottom, 30)
                        .shadow(color: Color("CardShadow"), radius: 3, x: 5, y: 5)
                        .shadow(color: Color("CardShadow"), radius: 3, x: -5, y: -5)
                    }
                }
            }

        )
    }
}

extension DetailedBikeRentalStationSheetView {

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

}
