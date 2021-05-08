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

    private var lastUpdated: LocalizedStringKey {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
        switch widgetDisplayType {
        case .preview:
            return LocalizedStringKey("stationInfoLastUpdatedToday \(formatter.string(from: Date()))")
        default:
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
    }

}

// MARK: - Views
extension WidgetStationCard {

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
                    lastUpdatedString: lastUpdated,
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
