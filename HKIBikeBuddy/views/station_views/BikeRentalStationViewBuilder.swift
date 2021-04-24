//
//  BikeRentalStationViewBuilder.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.4.2021.
//

import Foundation
import SwiftUI

class BikeRentalStationViewBuilder {

    static let shared = BikeRentalStationViewBuilder()

    private var stationInfoColor: Color {
        Color(Color.RGBColorSpace.sRGB, white: 0.5, opacity: 0.1)
    }

    private init() {}

    private func getFontSize(_ bikeRentalStationViewType: BikeRentalStationViewType) -> CGFloat {
        switch bikeRentalStationViewType {
        case .card:
            return CGFloat(24)
        case .detailed:
            return CGFloat(38)
        case .widgetCard:
            return CGFloat(30)
        case .widgetSquare:
            return CGFloat(20)
        }
    }

    @ViewBuilder func nameAndFavouriteStatusComponent(
        name: String,
        favouriteStatus: Binding<Bool>,
        favouriteAction: @escaping () -> Void,
        bikeRentalStationViewType: BikeRentalStationViewType
    ) -> some View {
        HStack {
            Text(name)
                .font(
                    .custom(
                        "Helvetica Neue Medium",
                        size: getFontSize(bikeRentalStationViewType)
                    )
                )
                .foregroundColor(Color("TextTitle"))

            Spacer()
            if bikeRentalStationViewType == BikeRentalStationViewType.card ||
                bikeRentalStationViewType == BikeRentalStationViewType.detailed {
                FavouriteMarker(
                    isActive: favouriteStatus,
                    action: { withAnimation { favouriteAction() } },
                    size: bikeRentalStationViewType == BikeRentalStationViewType.detailed ? .large : .small
                )
            }

        }
    }

    @ViewBuilder func distanceFromUserComponent(
        distanceFromUserString: String = "",
        lastUpdatedString: String = "",
        bikeRentalStationViewType: BikeRentalStationViewType
    ) -> some View {
        HStack {
            if bikeRentalStationViewType != .widgetCard {
                Image(systemName: "figure.walk")
                    .font(.footnote)
                    .foregroundColor(Color("TextMain"))
                Text("\(distanceFromUserString) away")
                    .foregroundColor(Color("TextMain"))
                    .font(.footnote)
            }

            if bikeRentalStationViewType == .detailed ||
                bikeRentalStationViewType == .widgetCard {

                if bikeRentalStationViewType == .detailed {
                    Divider()
                        .frame(height: 15)
                }

                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(bikeRentalStationViewType == .detailed ? .footnote : .caption2)
                    .foregroundColor(Color("TextMain"))

                Text(lastUpdatedString)
                    .font(bikeRentalStationViewType == .detailed ? .footnote : .caption2)
                    .foregroundColor(Color("TextMain"))

            }
            Spacer()
        }
    }

    func bikeAmountsComponent(
        bikes: Int,
        spaces: Int,
        state: Bool
    ) -> AnyView {
        if state {
            return AnyView(
                bikeAmountsInUseComponent(bikes: bikes, spaces: spaces)
                    .cornerRadius(10)
            )
        }
        return AnyView(
            bikeAmountsNotInUseComponent(bikes: bikes, space: spaces)
                .cornerRadius(10)
        )
    }

    @ViewBuilder private func bikeAmountsInUseComponent(
        bikes: Int,
        spaces: Int
    ) -> some View {
        VStack {
            CapacityBar(leftValue: bikes, rightValue: spaces)
            HStack {
                Text("\(bikes) bikes")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextMain"))
                Spacer()
                Text("\(spaces) spaces")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextMain"))
            }
            .padding(.horizontal, 10)
        }
    }

    @ViewBuilder private func bikeAmountsNotInUseComponent(
        bikes: Int,
        space: Int
    ) -> some View {
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
    }
}

extension BikeRentalStationViewBuilder {

    enum BikeRentalStationViewType {
        case card
        case detailed
        case widgetCard
        case widgetSquare
    }

}
