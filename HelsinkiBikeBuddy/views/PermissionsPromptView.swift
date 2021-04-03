//
//  PermissionsPromptView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 12.3.2021.
//

import SwiftUI

struct PermissionsPromptView: View {

    @EnvironmentObject var appState: AppState

    let locationPromptText =
        "HKI Bike Buddy uses the location information of your device to determine the nearest bike rental stations." +
        " To start using this application you have to grant it access to the location services."

    let locationPromptTextFromSettings =
        "HKI Bike Buddy uses the location information of your device to determine the nearest bike rental stations." +
        " To start using this application you have to grant it access to the location services. \n \n " +
        "To to this you have to go to Settings -> Privacy -> Location Services -> Helsinki Bike Buddy"

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            Image("PermissionPromptBg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.top)

            content
                .padding([.leading, .trailing], 15)

        }
    }

    var content: AnyView {
        if appState.locationServicesPromptDisplayed {
            return AnyView(
                Group {
                    VStack(alignment: .leading) {
                        Text("Before we get started,")
                            .font(.custom("Helvetica Neue Bold", size: 35))
                            .foregroundColor(Color("TextTitle"))
                            .padding([.bottom], 5)

                        Text(locationPromptTextFromSettings)
                            .multilineTextAlignment(.leading)
                            .padding([.bottom], 10)

                    }
                    .padding(15)
                }
            )
        }

        return AnyView(
            VStack {
                VStack(alignment: .leading) {
                    Text("Before we get started,")
                        .font(.custom("Helvetica Neue Bold", size: 35))
                        .foregroundColor(Color("TextTitle"))
                        .padding([.bottom], 5)
                    Text(locationPromptText)
                        .multilineTextAlignment(.leading)
                        .padding([.bottom], 10)
                    PrettyButton(textToDisplay: "Enable location services", perform: {
                        appState.requestLocationAuthorization()
                        appState.locationServicesRequested()
                    })
                }
                .padding(15)
            }
        )
    }
}

struct PermissionsPromptView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsPromptView()
    }
}
