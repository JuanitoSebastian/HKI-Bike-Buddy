//
//  CapacityBar.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.2.2021.
//

import SwiftUI

struct CapacityBar: View {

    let bikesAvailable: Int
    let spacesAvailable: Int

    var body: some View {
        barToDisplay
            .frame(height: 15)

    }

    var barToDisplay: AnyView {
        if bikesAvailable > 0 {
            return bikesAreAvailableBar
        }
        return noBikesAreAvailableBar
    }

    var noBikesAreAvailableBar: AnyView {
        AnyView(
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color("CapacityBarBg"))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .cornerRadius(10)
                }
            }
        )
    }

    var bikesAreAvailableBar: AnyView {
        AnyView(
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color("CapacityBarBg"))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .cornerRadius(10)

                    Rectangle()
                        .frame(
                            width: progressWidth(fullWidth: geometry.size.width),
                            height: geometry.size.height - 2
                        )
                        .cornerRadius(8)
                        .padding([.leading], 2)
                        .foregroundColor(capacityColor)
                }
            }
        )
    }

    func progressWidth(fullWidth: CGFloat) -> CGFloat {
        return fullWidth * CGFloat(factor)
    }

    var capacityColor: Color {
        // if factor < 0.3 { return Color("CapacityBarBikesLow") }
        return Color("CapacityBarBikesNormal")
    }

    var factor: Double {
        return Double(bikesAvailable) / Double(spacesAvailable + bikesAvailable)
    }

}

struct CapacityBar_Previews: PreviewProvider {
    static var previews: some View {
        CapacityBar(bikesAvailable: 2, spacesAvailable: 8)
    }
}
