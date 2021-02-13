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
                        .font(.largeTitle)
                        .foregroundColor(Color("TextMain"))
                    Spacer()
                    Text("Last updated at \(viewModel.fetched)")
                        .font(.caption)
                        .foregroundColor(Color("TextSub"))
                }
                HStack {
                    Text("\(viewModel.distanceInMeters()) away 🚶")
                        .foregroundColor(Color("TextMain"))
                    Spacer()
                }
                ZStack {
                    CapacityBar(bikesAvailable: viewModel.bikes, spacesAvailable: viewModel.spaces)
                    HStack {
                        Text("\(viewModel.bikes) bikes")
                            .font(.headline)
                        Spacer()
                        Text("\(viewModel.spaces) spaces")
                            .font(.headline)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                }
            }
            .padding([.bottom], 10)
            .padding([.top, .leading, .trailing], 5)
        }
        .padding([.top, .horizontal], 10)
        .cornerRadius(10)
    }

    func deleteStation() {
        viewModel.deleteStation()
    }
}
/*
struct BikeRentalStationView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.testing.container.viewContext
        let bikeRentalStation = createBikeRentalStation(viewContext: context)
        BikeRentalStationView(viewModel: BikeRentalStationViewModel(stationId: "074"))
    }
}
*/

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
