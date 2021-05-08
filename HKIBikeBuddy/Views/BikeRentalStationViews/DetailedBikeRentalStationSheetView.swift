//
//  DetailedBikeRentalStationSheetView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.4.2021.
//

import SwiftUI

/// A Detailed view of a Bike Rental Station 🚴
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
                        distanceFromUser: distance,
                        lastUpdatedString: lastUpdated,
                        bikeRentalStationViewType: .detailed
                    )
                    .padding(.horizontal, 15)
                    .padding(.bottom, 2)

                    ScrollView(.horizontal) {
                        HStack {
                            TextTag(
                                bikeRentalStation.state == BikeRentalStation.State.inUse ?
                                    LocalizedStringKey("textTagStationInUse") :
                                    LocalizedStringKey("textTagStationNotInUse"),
                                underlineColor: bikeRentalStation.state == BikeRentalStation.State.inUse ?
                                    Color("GreenUnderline") : Color("RedUnderline")
                            )
                            TextTag(
                                bikeRentalStation.allowDropoff ?
                                    LocalizedStringKey("textTagStationDropoffAllowed") :
                                    LocalizedStringKey("textTagStationDropoffNotAllowed"),
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
                                state: bikeRentalStation.state == BikeRentalStation.State.inUse
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
                appState.startMonitoringUserLocation()
            }
            .onDisappear {
                appState.stopMonitoringUserLocation()
            }

        )
    }
}

// MARK: - Functions and properties
extension DetailedBikeRentalStationSheetView {

    private var lastUpdated: LocalizedStringKey {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")

        if calendar.isDateInToday(bikeRentalStation.fetched) {
            let dateString = formatter.string(from: bikeRentalStation.fetched)
            return LocalizedStringKey("stationInfoLastUpdatedToday \(dateString)")
        }

        if calendar.isDateInYesterday(bikeRentalStation.fetched) {
            let dateString = formatter.string(from: bikeRentalStation.fetched)
            return LocalizedStringKey("stationInfoLastUpdatedYesterday \(dateString)")
        }
        return LocalizedStringKey("stationInfoLastUpdatedProlonged")
    }

    private var distance: LocalizedStringKey {
        guard let userLocation = appState.userLocation else {
            return LocalizedStringKey("")
        }

        var distanceDouble = Int(
            Double.roundToNearest(
                bikeRentalStation.location.distance(from: userLocation), toNearest: 20
            )
        )

        if distanceDouble >= 1000 {
            distanceDouble /= 1000
            return LocalizedStringKey("stationInfoDistanceKm \(String(distanceDouble))")
        }

        return LocalizedStringKey("stationInfoDistanceM \(String(distanceDouble))")
    }

    private func toggleFavourite() {
        if toggleTriggered { return }
        toggleTriggered = true
        Haptics.shared.feedback(intensity: .medium, delay: 750)

        if bikeRentalStation.favourite {
            appState.markStationAsNonFavourite(bikeRentalStation)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                withAnimation(.spring()) {
                    appState.removeStationFromFavouritesList(bikeRentalStation)
                    self.toggleTriggered = false
                }
            }
        } else {
            appState.markStationAsFavourite(bikeRentalStation)
            withAnimation(.spring()) {
                appState.addStationToFavouritesList(bikeRentalStation)
                toggleTriggered = false
            }
        }
    }

}
