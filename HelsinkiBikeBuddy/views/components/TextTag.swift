//
//  TextTag.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 15.4.2021.
//

import SwiftUI

struct TextTag: View {

    let textToDisplay: String
    let textColor: Color
    let backgroundColor: Color
    let underlineColor: Color

    init(_ textToDisplay: String,
         textColor: Color = Color("TextMain"),
         backgroundColor: Color = Color("TextTagBg"),
         underlineColor: Color = Color.gray.opacity(0.5)
    ) {
        self.textToDisplay = textToDisplay
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.underlineColor = underlineColor
    }

    var body: some View {
        Text(textToDisplay)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(5)
            .frame(height: 30)
            .overlay(underline, alignment: .bottom)
    }

    var underline: AnyView {
        return AnyView(
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(underlineColor.opacity(0.5))
                .frame(height: 2)
                .padding(.horizontal, 6)
                .padding(.bottom, 3)
                .shadow(color: underlineColor.opacity(0.3), radius: 2)
        )
    }
}

#if DEBUG
struct TextTag_Previews: PreviewProvider {
    static var previews: some View {
        TextTag("Updated 12.31")
    }
}
#endif
