//
//  FavoriteMarker.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 19.2.2021.
//

import SwiftUI
/// A heart shaped button. 💘
struct FavouriteMarker: View {

    @Binding var isActive: Bool
    let action: () -> Void
    let size: HeartSize

    /// - Parameter isActive: Is the heart filled or not?
    /// - Parameter action: What is performed on tap?
    /// - Parameter size: What size should the heart be?
    init(
        isActive: Binding<Bool>,
        action: @escaping () -> Void,
        size: HeartSize = .small
    ) {
        self._isActive = isActive
        self.action = action
        self.size = size
    }
}

// MARK: - Views
extension FavouriteMarker {
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "heart.fill")
                .foregroundColor(isActive ? Color("FavoriteHeart") : Color("UnFavoriteHeart"))
                .shadow(color: Color("FavoriteHeartGlow"), radius: isActive ? 3 : 0)
                .font(.system(size: size.rawValue))
        }
        .buttonStyle(StaticHighPriorityButtonStyle())
    }
}

// MARK: - Enums
extension FavouriteMarker {
    public enum HeartSize: CGFloat {
        case small = 20
        case large = 32
    }
}

// MARK: - Previews
#if DEBUG
struct FavoriteMarker_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteMarker(isActive: .constant(true), action: { Log.i("Favorite marker tapped") })
    }
}
#endif
