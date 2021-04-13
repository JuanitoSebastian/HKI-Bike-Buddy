//
//  Card.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 11.4.2021.
//

import SwiftUI

struct Card<Content: View>: View {

    private let builder: () -> Content

    init(@ViewBuilder _ builder: @escaping () -> Content) {
        self.builder = builder
    }

    var body: some View {
        ZStack {
            builder()
                .padding([.leading, .trailing], 15)
                .padding([.top], 5)
                .padding([.bottom], 10)
        }
        .background(Color("CardBg"))
        .cornerRadius(10)
        .shadow(color: Color("CardShadow"), radius: 3, x: 5, y: 5)
        .shadow(color: Color("CardShadow"), radius: 3, x: -5, y: -5)
    }
}

#if DEBUG
struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card {
            VStack {
                HStack {
                    Spacer()
                    Text("This is a card")
                    Spacer()
                }
            }
        }
    }
}
#endif
