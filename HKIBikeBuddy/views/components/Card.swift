//
//  Card.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 11.4.2021.
//

import SwiftUI

/// A pretty looking card where content can be placed
struct Card<Content: View>: View {

    private let builder: () -> Content
    private let shadowColor: Color
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat

    init(
        shadowColor: Color = Color("CardShadow"),
        horizontalPadding: CGFloat = 10,
        verticalPadding: CGFloat = 10,
        @ViewBuilder _ builder: @escaping () -> Content
    ) {
        self.builder = builder
        self.shadowColor = shadowColor
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    var body: some View {
        ZStack {
            builder()
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
        }
        .background(Color("CardBg"))
        .cornerRadius(10)
        .shadow(color: shadowColor, radius: 3, x: 5, y: 5)
        .shadow(color: shadowColor, radius: 3, x: -5, y: -5)
    }
}

// MARK: - Preview
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
