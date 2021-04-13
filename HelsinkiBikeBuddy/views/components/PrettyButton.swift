//
//  PrettyButton.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.3.2021.
//

import SwiftUI

struct PrettyButton: View {

    let textToDisplay: String
    let perform: () -> Void

    var body: some View {
        Button { perform() } label: {
            Text(textToDisplay)
                .font(.headline)
                .foregroundColor(Color("PrettyButtonTxt"))
                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                .background(
                    Color("PrettyButtonBg")
                        .cornerRadius(5)
                )
        }
        .onTapGesture {

        }
    }
}

struct PrettyButton_Previews: PreviewProvider {
    static var previews: some View {
        PrettyButton(textToDisplay: "Save settings!", perform: { Helper.log("Just pressed a pretty button!") })
    }
}
