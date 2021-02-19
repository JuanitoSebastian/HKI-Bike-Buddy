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
        .padding([.top, .bottom], 10)
        .cornerRadius(10)
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
