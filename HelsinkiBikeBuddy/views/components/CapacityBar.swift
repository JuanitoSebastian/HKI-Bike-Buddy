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
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color("CapacityBarBackground"))
                    .frame(width: geometry.size.width, height: geometry.size.height)

                Rectangle().frame(width: progressWidth(fullWidth: geometry.size.width), height: geometry.size.height)
                    .foregroundColor(progressColor)
                    .animation(.easeInOut)
            }
        }
        .frame(height: 20)
    }

    func progressWidth(fullWidth: CGFloat) -> CGFloat {
        return fullWidth * CGFloat(factor)
    }

    var progressColor: Color {
        return Color("TextMain")
    }

    var factor: Double {
        Double(bikesAvailable) / Double(spacesAvailable + bikesAvailable)
    }

    var factorInvert: Double {
        Double(spacesAvailable) / Double(spacesAvailable + bikesAvailable)
    }
}

struct CapacityBar_Previews: PreviewProvider {
    static var previews: some View {
        CapacityBar(bikesAvailable: 4, spacesAvailable: 6)
    }
}
