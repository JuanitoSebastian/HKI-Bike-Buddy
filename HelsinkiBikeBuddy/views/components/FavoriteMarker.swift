//
//  FavoriteMarker.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 19.2.2021.
//

import SwiftUI

struct FavoriteMarker: View {

    let isFavorite: Bool

    var body: some View {
        if isFavorite {
            Image(systemName: "heart.fill")
                .foregroundColor(Color("FavoriteHeart"))
                .font(.system(size: 28))
                .shadow(color: Color("FavoriteHeartGlow"), radius: 5)
        } else {
            Image(systemName: "heart")
                .foregroundColor(Color("UnFavoriteHeart"))
                .font(.system(size: 28))
        }
    }
}

struct FavoriteMarker_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteMarker(isFavorite: true)
    }
}
