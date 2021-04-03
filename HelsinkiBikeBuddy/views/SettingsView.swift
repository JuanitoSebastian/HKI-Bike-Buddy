//
//  SettingsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 9.3.2021.
//

import SwiftUI

// TODO: Custom back button here, so that api fetch is performed when return back to main view

struct SettingsView: View {

    @EnvironmentObject var appState: AppState
    @State var nearbyRange: Double = 1000

    init() {
        // This makes the custom background color visible
        UITableView.appearance().backgroundColor = .clear
    }

    var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("NEARBY STATIONS")) {
                    VStack {
                        Text("Distance to nearby stations:")
                            .font(.headline)
                            .foregroundColor(Color("TextMain"))
                        Slider(
                            value: $nearbyRange,
                            in: 250...5000,
                            step: 250,
                            onEditingChanged: { editing in
                                if editing { return }
                                appState.setNearbyRadius(radius: Int(nearbyRange))
                                appState.fetchFromApi()
                            }
                        )
                        Text("\(Int(nearbyRange)) meters")
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
                    Text("HKI Bike Buddy by ")
                        .font(.footnote)
                        .padding([.bottom], 5)
                    Button { openJuanitoHomepage() } label: {
                        Text("juan.fi")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding([.bottom], 5)
                    }
                }
                Text("Data provided by © Helsinki Region Transport \(currentYear)")
                    .font(.footnote)
            }
        }
        .padding([.bottom], 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("AppBackground")
        )
        .navigationTitle(Text("Settings"))
        .onAppear(perform: {
            nearbyRange = Double(appState.nearbyRadius)
        })
    }

    // MARK: - Functions
    func openJuanitoHomepage() {
        UIApplication.shared.open(URL(string: "https://juan.fi")!, options: [:], completionHandler: nil)
    }
}
