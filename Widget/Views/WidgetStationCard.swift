//
//  WidgetStationCard.swift
//  BikeBuddyWidgetExtension
//
//  Created by Juan Covarrubias on 19.4.2021.
//

import SwiftUI

struct WidgetStationCard: View {

    let bikeRentalStation: BikeRentalStation
    let widgetDisplayType: BikeRentalStationWidgetEntry.WidgetDisplayType

    var fetchedDate: Date {
        switch widgetDisplayType {
        case .operational:
            return bikeRentalStation.fetched
        case .preview:
            return Date()
        }
    }

    var lastUpdatedString: String {
        switch widgetDisplayType {
        case .operational:
            return bikeRentalStation.lastUpdatedString
        case .preview:
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("HH:mm")
            return "Updated \(formatter.string(from: Date()))"
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                BikeRentalStationViewBuilder.shared.nameAndFavouriteStatusComponent(
                    name: bikeRentalStation.name,
                    favouriteStatus: .constant(bikeRentalStation.favourite),
                    favouriteAction: {},
                    bikeRentalStationViewType: .widgetCard
                )

                BikeRentalStationViewBuilder.shared.distanceFromUserComponent(
                    lastUpdatedString: bikeRentalStation.lastUpdatedString,
                    bikeRentalStationViewType: .widgetCard
                )
                .padding(.bottom, 2)

                HStack {
                    TextTag(
                        bikeRentalStation.allowDropoff ?
                            LocalizedStringKey("textTagStationDropoffAllowed") :
                            LocalizedStringKey("textTagStationDropoffNotAllowed"),
                        underlineColor: bikeRentalStation.allowDropoff ?
                            Color("GreenUnderline") :
                            Color("RedUnderline")
                    )
                    Spacer()
                }
                .padding(.bottom, 2)

                BikeRentalStationViewBuilder.shared.bikeAmountsComponent(
                    bikes: bikeRentalStation.bikes,
                    spaces: bikeRentalStation.spaces,
                    state: bikeRentalStation.state == BikeRentalStation.State.inUse
                )
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
        }
    }
}
