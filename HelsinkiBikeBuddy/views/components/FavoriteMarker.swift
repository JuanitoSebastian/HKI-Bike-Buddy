//
//  FavoriteMarker.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 19.2.2021.
//

import SwiftUI
/**
 A heart shaped button.
 - Parameter isActive: Has the heart been tapped?
 - Parameter action: What is performed on tap.
 */
struct FavoriteMarker: View {

    @Binding var isActive: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            heart
        }
    }

    var heart: AnyView {

        if isActive {
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
        FavoriteMarker(isActive: .constant(true), action: { Log.i("Favorite marker tapped") })
    }
}
