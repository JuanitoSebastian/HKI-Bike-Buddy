//
//  SettingsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 9.3.2021.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var viewModel = SettingsViewModel.shared

    init() {
        UITableView.appearance().backgroundColor = .clear
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("BIKE RENTAL STATIONS")) {
                    VStack {
                        Text("Maximum distance to a nearby station:")
                            .font(.headline)
                            .foregroundColor(Color("TextMain"))
                        Slider(
                            value: $viewModel.nearbyRange,
                            in: 250...5000,
                            step: 250,
                            onEditingChanged: { editing in
                                if editing { return }
                                viewModel.saveSettings()
                            }
                        )
                        Text("\(viewModel.nearbyRangeInt) meters")
                            .foregroundColor(Color("TextMain"))
                    }
                }

                .padding(10)
            }
            .background(
                Color("AppBackground")
            )
            Spacer()
            VStack {
                HStack(spacing: 0) {
                    Text("HKI Bike Buddy is developed by ")
                        .font(.footnote)
                        .padding([.bottom], 5)
                    Button { viewModel.openJuanitoHomepage() } label: {
                        Text("juan.fi")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding([.bottom], 5)
                    }
                }
                Text("Data provided by © Helsinki Region Transport \(viewModel.currentYear)")
                    .font(.footnote)
            }
        }
        .padding([.bottom], 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("AppBackground")
        )
        .navigationTitle(Text("Settings"))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
