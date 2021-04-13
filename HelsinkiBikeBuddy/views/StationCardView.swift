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
    @ObservedObject var rentalStation: BikeRentalStation
    @State var toggleTriggered: Bool = false
    @Binding var detailed: Bool
    @State var longPress = false

    private var bikes: Int {
        rentalStation.bikes ?? 0
    }

    private var spaces: Int {
        rentalStation.spaces ?? 0
    }

    private var stationInfoColor: Color {
        Color(Color.RGBColorSpace.sRGB, white: 0.5, opacity: 0.1)
    }

    private var state: RentalStationState {
        guard let unwrappedState = rentalStation.state else { return .loading }
        return unwrappedState ? .inUse : .notInUse
    }

    private var distanceString: String {
        guard let userLocation = appState.userLocation,
              let stationLocation = rentalStation.location else {
            return "-"
        }

        var distanceDouble = Int(
            Helper.roundToNearest(
                stationLocation.distance(from: userLocation), toNearest: 20
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
        GeometryReader { geometry in
            Card {
                content
            }
            .gesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        withAnimation {
                            appState.detailedViewMidY = geometry.frame(in: CoordinateSpace.global).minY + 15
                            Haptics.shared.feedback(intensity: .hard)
                            longPressAction()
                        }
                    }
            )
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .frame(height: 140)
    }

    /// Determines which of the views to display
    private var content: AnyView {
        switch state {
        case .loading:
            return stationIsLoading
        default:
            return stationCard
        }
    }

    // Contents for when station is in use
    private var stationCard: AnyView {
        AnyView(
            VStack {
                nameAndFavouriteStatusComponent

                distanceFromUserComponent
                    .padding([.bottom], 5)

                bikeAmountsComponent
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, stationInfoColor]),
                            startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(10)

                if detailed == true {
                    MapView(rentalStation: rentalStation)
                        .frame(height: 400)
                    PrettyButton(textToDisplay: "Dismiss", perform: { Log.i( appState.toggleDetailedView() )})
                }
            }
        )
    }

    // Contents for when station is loading
    private var stationIsLoading: AnyView {
        AnyView(
            VStack {

                nameAndFavouriteStatusComponent

                SquarePlaceholder()
                    .frame(height: 50)
            }
        )
    }

    /// HStack with name and FavouriteMarker
    private var nameAndFavouriteStatusComponent: AnyView {
        AnyView(
            HStack {
                Text(rentalStation.name)
                    .font(.custom("Helvetica Neue Medium", size: 24))
                    .foregroundColor(Color("TextTitle"))

                Spacer()

                FavoriteMarker(isActive: $rentalStation.favourite, action: {
                    withAnimation {
                        toggleFavourite()
                    }
                })
            }
        )
    }

    /// HStack with distance from user
    private var distanceFromUserComponent: AnyView {
        AnyView(
            HStack {
                Text("\(distanceString) away")
                    .foregroundColor(Color("TextMain"))
                Spacer()
            }
        )
    }

    private var bikeAmountsComponent: AnyView {
        switch state {
        case .notInUse:
            return amountComponentNotInUse
        default:
            return amountComponentInUse
        }
    }

    private var amountComponentInUse: AnyView {
        AnyView(
            VStack {
                CapacityBar(leftValue: bikes, rightValue: spaces)
                    .shadow(color: Color("CardShadow"), radius: 3, x: 0, y: 3)
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
        )
    }

    private var amountComponentNotInUse: AnyView {
        AnyView(
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
        )
    }
}
// MARK: - Functions
extension StationCardView {
    private func toggleFavourite() {
        if toggleTriggered { return }
        toggleTriggered = true
        Haptics.shared.feedback(intensity: .medium, delay: 750)

        if rentalStation.favourite {
            rentalStation.favourite.toggle()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                withAnimation(.spring()) {
                    appState.unFavouriteRentalStation(rentalStation)
                    self.toggleTriggered = false
                }
            }
        } else {
            rentalStation.favourite.toggle()
            withAnimation(.spring()) {
                appState.favouriteRentalStation(rentalStation)
                toggleTriggered = false
            }
        }
    }

    private func longPressAction() {
        Log.i("Long press")
        appState.setDetailedViewStatation(rentalStation)
        appState.toggleDetailedView()
    }

}

// MARK: - Enums
extension StationCardView {
    enum RentalStationState {
        case inUse
        case notInUse
        case loading
    }
}

#if DEBUG
struct StationCardView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let bikeRentalStation = BikeRentalStation(stationId: "014", name: "Senaatintori")
        StationCardView(rentalStation: bikeRentalStation, detailed: .constant(false))
            .environmentObject(appState)
    }
}
#endif
