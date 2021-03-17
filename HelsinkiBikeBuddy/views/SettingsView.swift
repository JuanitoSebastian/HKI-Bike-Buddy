//
//  SettingsView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 9.3.2021.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var viewModel = SettingsViewModel.shared

    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Text("Maximum distance to a nearby station:")
                        .font(.headline)
                        .foregroundColor(Color("TextMain"))
                    Slider(
                        value: $viewModel.nearbyRange,
                        in: 250...5000,
                        step: 250,
                        onEditingChanged: { editing in
                            viewModel.nearbyRangeEditing = editing
                        }
                    )
                    Text("\(viewModel.nearbyRangeInt) meters")
                        .foregroundColor(Color("TextMain"))
                    PrettyButton(textToDisplay: "Save settings!", perform: { viewModel.saveSettings() })
                        .padding([.top, .bottom], 5)
                }
                .padding([.leading, .trailing], 15)
                .padding([.top, .bottom], 10)
            }
            .background(Color("StationCardBg"))
            .cornerRadius(10)
            .padding([.leading, .trailing, .top], 10)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: 5, y: 5)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: -5, y: -5)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("AppBackground")
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
