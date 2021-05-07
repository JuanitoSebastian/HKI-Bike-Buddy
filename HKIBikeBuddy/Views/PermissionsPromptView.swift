//
//  PermissionsPromptView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 12.3.2021.
//

import SwiftUI

/// View asking for permission to use location services 📍
struct PermissionsPromptView: View {

    @EnvironmentObject var appState: AppState

}

// MARK: - Views
extension PermissionsPromptView {

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
                        Text(LocalizedStringKey("headerTitlePermissionsPrompt"))
                            .font(.custom("Helvetica Neue Bold", size: 30))
                            .foregroundColor(Color("TextTitle"))
                            .padding([.bottom], 5)

                        Text(LocalizedStringKey("infoMessagePermissionPrompt"))
                            .multilineTextAlignment(.leading)
                            .padding([.bottom], 10)

                        HStack {
                            TextTag(LocalizedStringKey("textTagSettings"),
                                    backgroundColor: Color.white,
                                    underlineColor: Color.white
                            )
                            Image(systemName: "arrow.right")
                                .font(.caption)
                            TextTag(
                                LocalizedStringKey("textTagPrivacy"),
                                backgroundColor: Color.white,
                                underlineColor: Color.white
                            )
                            Image(systemName: "arrow.right")
                                .font(.caption)
                        }
                        .padding(.bottom, 2)
                        HStack {
                            TextTag(
                                LocalizedStringKey("textTagLocationServices"),
                                backgroundColor: Color.white,
                                underlineColor: Color.white
                            )
                            Image(systemName: "arrow.right")
                                .font(.caption)
                            TextTag(
                                LocalizedStringKey("textTagHkiBikeBuddy"),
                                backgroundColor: Color.white,
                                underlineColor: Color.white
                            )
                        }

                    }
                    .padding(15)
                }
            )
        }

        return AnyView(
            VStack {
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey("headerTitlePermissionsPrompt"))
                        .font(.custom("Helvetica Neue Bold", size: 30))
                        .foregroundColor(Color("TextTitle"))
                        .padding([.bottom], 5)
                    Text(LocalizedStringKey("infoMessagePermissionPromptFirstTime"))
                        .multilineTextAlignment(.leading)
                        .padding([.bottom], 10)
                    Button { appState.requestLocationAuthorization() } label: {
                        Text(LocalizedStringKey("buttonEnableLocationServices"))
                    }.buttonStyle(PrettyButton())
                }
                .padding(15)
            }
        )
    }
}

// MARK: - Preview
#if DEBUG
struct PermissionsPromptView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsPromptView()
            .environmentObject(AppState.shared)
    }
}
#endif
