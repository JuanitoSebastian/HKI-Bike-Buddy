//
//  RentalStationView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 26.3.2021.
//

import SwiftUI

/// A card view of a single RentalStation
struct BikeRentalStationCardView {

    let bikeRentalStation: RentalStation
    @State var favouriteStatus: Bool
    @State var toggleTriggered: Bool

    init(rentalStation: RentalStation) {
        self.bikeRentalStation = rentalStation
        self._favouriteStatus = State(initialValue: rentalStation.favourite)
        self._toggleTriggered = State(initialValue: false)
    }

    var spaces: Int {
        Int(bikeRentalStation.spacesAvailable)
    }

    var bikes: Int {
        Int(bikeRentalStation.bikesAvailable)
    }

    var stationInfoColor: Color {
        Color(Color.RGBColorSpace.sRGB, white: 0.5, opacity: 0.1)
    }
}

// MARK: - Functions
extension BikeRentalStationCardView {
    /// Toggles the favourite status of the rentalStation
    func toggleFavourite() {
        if toggleTriggered { return }
        toggleTriggered = true

        // Delay added for more natural haptic feedback
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }

        favouriteStatus.toggle()

        if bikeRentalStation.favourite {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                BikeRentalStationStore.shared.unfavouriteStation(rentalStation: self.bikeRentalStation)
                self.toggleTriggered = false
            }
        } else {
            BikeRentalStationStore.shared.favouriteStation(rentalStation: bikeRentalStation)
            toggleTriggered = false
        }
    }

    /// Returns the distance from rental station to the current location of the user
    func distanceToUser() -> String {
        guard let userLocation = UserLocationService.shared.userLocation else {
            return "-"
        }

        var distanceDouble = Int(
            Helper.roundToNearest(
                bikeRentalStation.location.distance(from: userLocation), toNearest: 20
            )
        )

        if distanceDouble >= 1000 {
            distanceDouble /= 1000
            return "\(String(distanceDouble)) km away"
        }

        return "\(String(distanceDouble)) m away"
    }
}

// MARK: - View
extension BikeRentalStationCardView: View {
    var body: some View {
        stationCard
            .background(Color("StationCardBg"))
            .cornerRadius(10)
            .animation(.spring())
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 15)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: 5, y: 5)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: -5, y: -5)
    }

    var stationCard: AnyView {
        AnyView(
            ZStack {
                VStack {
                    HStack {
                        Text(bikeRentalStation.name)
                            .font(.custom("Helvetica Neue Medium", size: 24))
                            .foregroundColor(Color("TextTitle"))
                        Spacer()
                        FavoriteMarker(isActive: favouriteStatus) {
                            toggleFavourite()
                        }
                    }

                    HStack {
                        Text(distanceToUser())
                            .foregroundColor(Color("TextMain"))
                        Spacer()
                    }
                    .padding([.bottom], 5)

                    bikeAmounts
                }
                .padding([.leading, .trailing], 15)
                .padding([.top], 5)
                .padding([.bottom], 10)
            }
        )
    }

    var bikeAmounts: AnyView {
        if bikeRentalStation.state {
            return AnyView(
                VStack {
                    CapacityBar(leftValue: bikes, rightValue: spaces)
                        .shadow(color: Color("StationCardShadow"), radius: 3, x: 0, y: 3)
                        .padding([.top], 2)
                    HStack {
                        Text("\(bikeRentalStation.bikesAvailable) bikes")
                            .font(.headline)
                            .foregroundColor(Color("TextMain"))
                        Spacer()
                        Text("\(bikeRentalStation.spacesAvailable) spaces")
                            .font(.headline)
                            .foregroundColor(Color("TextMain"))
                    }
                    .padding([.leading, .trailing, .bottom], 10)
                }
                .background(
                    LinearGradient(
                                gradient: Gradient(colors: [.clear, stationInfoColor]),
                                startPoint: .top, endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            )
        }

        return AnyView(
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
                    startPoint: .top, endPoint: .bottom
                )
            )
            .cornerRadius(10)
        )
    }
}

// MARK: - Preview
#if DEBUG
struct RentalStationView_Previews: PreviewProvider {
    static var previews: some View {
        let previewStation = UnmanagedBikeRentalStation(
            stationId: "014",
            name: "Senaatintori",
            allowDropoff: true,
            bikesAvailable: 4,
            fetched: Date(),
            lat: -1,
            lon: -1,
            spacesAvailable: 16,
            state: true
        )
        BikeRentalStationCardView(rentalStation: previewStation)
    }
}
#endif
