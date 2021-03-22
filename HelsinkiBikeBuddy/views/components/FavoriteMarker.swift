//
//  FavoriteMarker.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 19.2.2021.
//

import SwiftUI

struct FavoriteMarker: View {

    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button {
            // Delay added for more natural haptic feedback
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
            }
            action()
        } label: {
            heart
        }
        .buttonStyle(StaticHighPriorityButtonStyle())
    }

    var heart: AnyView {

        if isFavorite {
            return AnyView(
                    Image(systemName: "heart.fill")
                        .foregroundColor(Color("FavoriteHeart"))
                        .font(.system(size: 20))
            )
        }

        return AnyView(
                Image(systemName: "heart")
                    .foregroundColor(Color("UnFavoriteHeart"))
                    .font(.system(size: 20))
        )

    }
}

struct FavoriteMarker_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteMarker(isFavorite: true, action: { Helper.log("Favorite marker tapped") })
    }
}
