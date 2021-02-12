//
//  BikeRentalStationView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.2.2021.
//

import SwiftUI
import CoreData

struct BikeRentalStationView: View {

    let viewModel: BikeRentalStationViewModel

    init(bikeRentalStation: BikeRentalStation) {
        self.viewModel = BikeRentalStationViewModel(bikeRentalStation: bikeRentalStation)
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(viewModel.name)
                        .font(.largeTitle)
                    Spacer()
                }
                HStack {
                    Text("\(viewModel.distanceInMeters()) away 🚶")
                    Spacer()
                }
                HStack {
                    Text("ID: \(viewModel.stationId)")
                        .font(.caption)

                    Text("Last updated at \(viewModel.fetched)")
                        .font(.caption)
                    Spacer()
                }
                CapacityBar(bikesAvailable: viewModel.bikes, spacesAvailable: viewModel.spaces)
            }
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 5)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .padding([.top, .horizontal], 10)
        .cornerRadius(10)
    }

    func deleteStation() {
        viewModel.deleteStation()
    }
}

struct BikeRentalStationView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.testing.container.viewContext
        let bikeRentalStation = createBikeRentalStation(viewContext: context)
        BikeRentalStationView(bikeRentalStation: bikeRentalStation)
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
    return bikeRentalStation
}
