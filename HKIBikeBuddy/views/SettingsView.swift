//
//  SettingsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 9.3.2021.
//

import SwiftUI

/// Settings view displayes the settings that can be edited and app credits 🔧
struct SettingsView: View {

    @EnvironmentObject var appState: AppState
    @State var nearbyRange: Double = 1000

    init() {
        // Makes custom background colors visible in Section view
        UITableView.appearance().backgroundColor = .clear
    }

    var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    // Removes trailing zeroes from double and converts to string
    var nearbyRangeKilometers: String {
        let range = nearbyRange / 1000
        let formatter = NumberFormatter()
        let number = NSNumber(value: range)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return String(formatter.string(from: number) ?? "")
    }

}

// MARK: - Views
extension SettingsView {

    var body: some View {
        VStack {
            Form {
                Section(header: Text(LocalizedStringKey("headerSettingsNearbyStations"))) {
                    VStack {
                        Text(LocalizedStringKey("labelSettingsMaxDistance"))
                            .font(.subheadline)
                            .foregroundColor(Color("TextMain"))
                        Slider(
                            value: $nearbyRange,
                            in: 250...5000,
                            step: 250,
                            onEditingChanged: { editing in
                                if editing { return }
                                appState.setNearbyRadius(radius: Int(nearbyRange))
                                appState.fetchFromApi()
                            },
                            minimumValueLabel: sliderTextLabel("0.2 km"),
                            maximumValueLabel: sliderTextLabel("5 km")
                        ) { EmptyView() } // Slider requires a label view even if it is now shown...

                        Text("~ \(nearbyRangeKilometers) km")
                            .foregroundColor(Color("TextMain"))
                            .font(.footnote)
                            .fontWeight(.bold)
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
                    Text(LocalizedStringKey("textTagHkiBikeBuddy"))
                        .font(.footnote)
                        .padding([.bottom], 5)
                    Button { openJuanitoHomepage() } label: {
                        Text(LocalizedStringKey("buttonJuanWebsite"))
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding([.bottom], 5)
                    }
                }
                Text(LocalizedStringKey("infoMessageDataProvided \(currentYear)"))
                    .font(.footnote)
            }
        }
        .padding([.bottom], 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("AppBackground")
        )
        .navigationTitle(Text(LocalizedStringKey("screenTitleSettings")))
        .onAppear(perform: {
            nearbyRange = Double(appState.nearbyRadius)
        })
    }

    @ViewBuilder func sliderTextLabel(_ text: String) -> some View {
        Text(text)
            .foregroundColor(Color("TextMain"))
            .font(.footnote)
    }

}

// MARK: - Functions
extension SettingsView {
    func openJuanitoHomepage() {
        UIApplication.shared.open(URL(string: "https://juan.fi")!, options: [:], completionHandler: nil)
    }
}

// MARK: - Preview
#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState.shared)
    }
}
#endif
