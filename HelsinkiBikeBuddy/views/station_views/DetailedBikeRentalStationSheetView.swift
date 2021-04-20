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
    @State var bikeAmountsOffset: CGFloat = 200

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
                VStack(spacing: 2) {
                    BikeRentalStationViewBuilder.shared.nameAndFavouriteStatusComponent(
                        name: bikeRentalStation.name,
                        favouriteStatus: $bikeRentalStation.favourite,
                        favouriteAction: toggleFavourite,
                        bikeRentalStationViewType: .detailed
                    )
                    .padding(.horizontal, 15)

                    BikeRentalStationViewBuilder.shared.distanceFromUserComponent(
                        distanceFromUserString: distanceString,
                        lastUpdatedString: bikeRentalStation.lastUpdatedString,
                        bikeRentalStationViewType: .detailed
                    )
                    .padding(.horizontal, 15)
                    .padding(.bottom, 2)

                    ScrollView(.horizontal) {
                        HStack {
                            TextTag(
                                bikeRentalStation.stationInUseString,
                                underlineColor: bikeRentalStation.state ?
                                    Color("GreenUnderline") : Color("RedUnderline")
                            )
                            TextTag(
                                bikeRentalStation.allowDropoffString,
                                underlineColor: bikeRentalStation.allowDropoff ?
                                    Color("GreenUnderline") : Color("RedUnderline")
                            )
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)

                    ZStack(alignment: .bottom) {

                        MapView(bikeRentalStation: bikeRentalStation)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                                    startPoint: UnitPoint(x: 0.5, y: 0.7),
                                    endPoint: .bottom
                                )
                            )

                        Card(shadowColor: Color("CardShadowDark")) {
                            BikeRentalStationViewBuilder.shared.bikeAmountsComponent(
                                bikes: bikeRentalStation.bikes,
                                spaces: bikeRentalStation.spaces,
                                state: bikeRentalStation.state
                            )
                        }
                        .offset(y: bikeAmountsOffset)
                        .animation(Animation.spring(response: 0.8), value: bikeAmountsOffset)
                        .padding([.horizontal], 15)
                        .padding(.bottom, 30)
                    }
                }
            }
            .onAppear {
                bikeAmountsOffset = 0
                appState.startUpdatingUserLocation()
            }
            .onDisappear {
                appState.stopUpdatingUserLocation()
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