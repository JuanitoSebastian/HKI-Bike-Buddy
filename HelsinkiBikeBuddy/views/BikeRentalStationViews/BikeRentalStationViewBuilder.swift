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

    @ViewBuilder func nameAndFavouriteStatusComponent(
        name: String,
        favouriteStatus: Binding<Bool>,
        favouriteAction: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(name)
                .font(.custom("Helvetica Neue Medium", size: 24))
                .foregroundColor(Color("TextTitle"))

            Spacer()

            FavoriteMarker(isActive: favouriteStatus, action: {
                withAnimation {
                    favouriteAction()
                }
            })
        }
    }

    @ViewBuilder func distanceFromUserComponent(
        distanceFromUserString: String
    ) -> some View {
        HStack {
            Text("\(distanceFromUserString) away")
                .foregroundColor(Color("TextMain"))
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
                    .background(
                        Color("StationInfoBg")
                    )
                    .cornerRadius(10)
            )
        }
        return AnyView(
            bikeAmountsNotInUseComponent(bikes: bikes, space: spaces)
                .background(
                    Color("StationInfoBg")
                )
                .cornerRadius(10)
        )
    }

    @ViewBuilder private func bikeAmountsInUseComponent(
        bikes: Int,
        spaces: Int
    ) -> some View {
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
