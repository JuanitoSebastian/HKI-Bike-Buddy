//
//  RentalStationCardView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 3.4.2021.
//

import SwiftUI
import CoreLocation

struct StationCardView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject var rentalStation: BikeRentalStation
    @State var favouriteStatus = false
    @State var toggleTriggered: Bool = false

    var body: some View {
        content
            .animation(.spring())
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 15)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: 5, y: 5)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: -5, y: -5)
            .onAppear(perform: {
                favouriteStatus = rentalStation.favourite
            })
    }

    private var bikes: Int {
        rentalStation.bikes ?? 0
    }

    private var spaces: Int {
        rentalStation.spaces ?? 0
    }

    private var coordinates: CLLocation {
        CLLocation(latitude: rentalStation.lat ?? -1, longitude: rentalStation.lon ?? -1)
    }

    private var stationInfoColor: Color {
        Color(Color.RGBColorSpace.sRGB, white: 0.5, opacity: 0.1)
    }

    private var state: RentalStationState {
        rentalStation.state ?? false ? .inUse : .notInUse
    }

    var content: AnyView {
        switch state {
        case .inUse:
            return stationInUseCard
        case .notInUse:
            return stationNotInUseCard
        }
    }

    // Contents for when station is in use
    var stationInUseCard: AnyView {
        AnyView(
            ZStack {
                VStack {
                    HStack {
                        Text(rentalStation.name)
                            .font(.custom("Helvetica Neue Medium", size: 24))
                            .foregroundColor(Color("TextTitle"))
                        Spacer()

                        FavoriteMarker(isActive: $favouriteStatus, action: {
                            withAnimation {
                                toggleFavourite()
                            }
                        })

                    }
                    HStack {
                        Text("\(distanceInMeters()) away")
                            .foregroundColor(Color("TextMain"))
                        Spacer()

                    }
                    .padding([.bottom], 5)
                    VStack {
                        CapacityBar(leftValue: bikes, rightValue: spaces)
                            .shadow(color: Color("StationCardShadow"), radius: 3, x: 0, y: 3)
                            .padding([.top], 2)
                        HStack {
                            Text("\(bikes) bikes")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                            Spacer()
                            Text("\(spaces) spaces")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                        }
                        .padding([.leading, .trailing, .bottom], 10)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, stationInfoColor]),
                            startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(10)

                }
                .padding([.leading, .trailing], 15)
                .padding([.top], 5)
                .padding([.bottom], 10)
            }
            .background(Color("StationCardBg"))
            .cornerRadius(10)
            .onTapGesture(count: 2) {
                withAnimation {

                }
            }
        )
    }

    // Contents for when station is not in use
    var stationNotInUseCard: AnyView {
        AnyView(
            ZStack {
                VStack {
                    HStack {
                        Text(rentalStation.name)
                            .font(.custom("Helvetica Neue Medium", size: 24))
                            .foregroundColor(Color("TextTitle"))
                        Spacer()

                        FavoriteMarker(isActive: $favouriteStatus, action: {
                            withAnimation {
                                toggleFavourite()
                            }
                        })

                    }
                    HStack {
                        Text("\(distanceInMeters()) away")
                            .foregroundColor(Color("TextMain"))
                        Spacer()

                    }
                    .padding([.bottom], 5)
                    VStack {
                        HStack {
                            Spacer()
                            Text("Station is not in use")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                            Spacer()
                        }
                        .padding(10)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, stationInfoColor]),
                            startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(10)

                }
                .padding([.leading, .trailing], 15)
                .padding([.top], 5)
                .padding([.bottom], 10)
            }
            .background(Color("StationCardBg"))
            .cornerRadius(10)
            .onTapGesture(count: 2) {
                withAnimation {

                }
            }
        )
    }

}
    // MARK: - Functions
extension StationCardView {
    func distanceInMeters() -> String {
        guard let userLocation = appState.userLocation else {
            return "User location unavailbale"
        }

        var distanceDouble = Int(
            Helper.roundToNearest(
                coordinates.distance(from: userLocation), toNearest: 20
            )
        )

        if distanceDouble >= 1000 {
            distanceDouble /= 1000
            return "\(String(distanceDouble)) km"
        }

        return "\(String(distanceDouble)) m"
    }

    func toggleFavourite() {
        if toggleTriggered { return }
        toggleTriggered = true
        let isStationFavourite = rentalStation.favourite ?? false

        favouriteStatus.toggle()
        hapticFeedback()
        if isStationFavourite {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                appState.unFavouriteRentalStation(rentalStation)
                self.toggleTriggered = false
            }
        } else {
            appState.favouriteRentalStation(rentalStation)
            toggleTriggered = false
        }
    }

    private func hapticFeedback() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .microseconds(750)) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// MARK: - Enums
extension StationCardView {
    enum RentalStationState {
        case inUse
        case notInUse
    }
}
