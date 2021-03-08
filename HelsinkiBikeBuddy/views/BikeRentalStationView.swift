//
//  BikeRentalStationView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI
import CoreData

struct BikeRentalStationView: View {

    @ObservedObject var viewModel: BikeRentalStationViewModel

    var body: some View {
        content
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 5)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: 0, y: 3)
            .blendMode(.softLight)
    }

    var content: AnyView {
        switch viewModel.state {

        // MARK: - - STATION AVAILABLE
        case BikeRentalStationViewState.normal:
            return AnyView(
                ZStack {
                    VStack {
                        HStack {
                            Text(viewModel.name)
                                .font(.custom("Helvetica Neue Condensed Bold", size: 35))
                                .foregroundColor(Color("TextTitle"))
                            Spacer()
                            FavoriteMarker(isFavorite: viewModel.favorite)
                                .onTapGesture {
                                    viewModel.toggleFav()
                                }
                        }
                        HStack {
                            Text("\(viewModel.distanceInMeters()) away 🚶")
                                .foregroundColor(Color("TextMain"))
                            Spacer()

                        }
                        .padding([.bottom], 5)
                        HStack {
                            Text("\(viewModel.bikes) bikes")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                            Spacer()
                            Text("\(viewModel.spaces) spaces")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                        }
                        CapacityBar(bikesAvailable: viewModel.bikes, spacesAvailable: viewModel.spaces)
                    }
                    .padding([.leading, .trailing], 15)
                    .padding([.top], 5)
                    .padding([.bottom], 10)
                }

                .background(Color("StationCardBg"))
                .cornerRadius(10)
                .padding([.leading, .trailing], 10)
                .onTapGesture(count: 2) {
                    viewModel.toggleFav()
                }
                .onTapGesture {
                    withAnimation {
                        DetailedBikeRentalStationViewModel.shared.bikeRentalStation = viewModel.bikeRentalStation
                        ContentViewModel.shared.mainViewContent = .overlayContent
                        OverlayContentViewController.shared.viewState = .detailedStation
                    }
                }
            )

        // MARK: - - STATION UNAVAILABLE
        case .unavailable:
            return AnyView(
                ZStack {
                    VStack {
                        HStack {
                            Text(viewModel.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TextMain"))
                            Spacer()
                            FavoriteMarker(isFavorite: viewModel.favorite)
                                .onTapGesture {
                                    viewModel.favorite = !viewModel.favorite
                                }
                        }
                        .padding([.leading, .trailing], 20)
                        HStack {
                            Text("\(viewModel.distanceInMeters()) away 🚶")
                                .foregroundColor(Color("TextMain"))
                            Spacer()

                        }
                        .padding([.leading, .trailing], 20)
                        .padding([.bottom], 5)
                        HStack {
                            Text("\(viewModel.bikes) bikes")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                            Spacer()
                            Text("\(viewModel.spaces) spaces")
                                .font(.headline)
                                .foregroundColor(Color("TextMain"))
                        }
                        .padding([.leading, .trailing], 20)
                        CapacityBar(bikesAvailable: viewModel.bikes, spacesAvailable: viewModel.spaces)

                    }
                }
            )
        }
    }

}

struct BikeRentalStationView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.testing.container.viewContext
        let bikeRentalStation = createBikeRentalStation(viewContext: context)
        BikeRentalStationView(viewModel: BikeRentalStationViewModel(bikeRentalStation: bikeRentalStation))
    }
}

func createBikeRentalStation(viewContext: NSManagedObjectContext) -> BikeRentalStation {
    let bikeRentalStation = BikeRentalStation(context: viewContext)
    bikeRentalStation.name = "Rajasaarentie"
    bikeRentalStation.stationId = "074"
    bikeRentalStation.lat = 44
    bikeRentalStation.lon = 123
    bikeRentalStation.allowDropoff = true
    bikeRentalStation.spacesAvailable = 4
    bikeRentalStation.bikesAvailable = 5
    bikeRentalStation.fetched = Date()
    bikeRentalStation.favorite = true
    return bikeRentalStation
}
