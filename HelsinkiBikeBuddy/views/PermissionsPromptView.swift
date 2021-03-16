//
//  PermissionsPromptView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 12.3.2021.
//

import SwiftUI

struct PermissionsPromptView: View {

    let locationPromptText =
    "Helsinki Bike Buddy uses the location information of your device to determine the nearest bike rental stations." +
    " To start using this application you have to grant it access to the location services."

    var body: some View {
        ZStack {
            Color("AppBackgroundNew").ignoresSafeArea()

            VStack {
                VStack {
                    HStack {
                        Text("Before you start,")
                            .font(.custom("Helvetica Neue Bold", size: 35))
                            .foregroundColor(Color("TextTitle"))
                            .padding([.bottom], 5)
                        Spacer()
                    }
                    Text(locationPromptText)
                        .multilineTextAlignment(.leading)
                        .padding([.bottom], 10)
                    PrettyButton(textToDisplay: "Enable location services", perform: { UserLocationManager.shared.requestPermissions() })
                }
                .padding(15)
            }
            .background(Color("StationCardBg"))
            .cornerRadius(10)
            .padding([.leading, .trailing], 15)
            .shadow(color: Color("StationCardShadow"), radius: 3, x: 0, y: 3)

        }
    }
}

struct PermissionsPromptView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsPromptView()
    }
}
