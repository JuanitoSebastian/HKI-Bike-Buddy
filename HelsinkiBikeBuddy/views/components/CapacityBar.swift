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
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                Rectangle().frame(width: progressWidth(fullWidth: geometry.size.width), height: geometry.size.height)
                    .foregroundColor(progressColor)
                    .animation(.linear)
                Text("🚴‍♀️")
                    .offset(x: progressWidth(fullWidth: geometry.size.width) - 25)
                    .animation(.linear)
            }
        }
        .frame(height: 20)
        .cornerRadius(20)
    }

    func progressWidth(fullWidth: CGFloat) -> CGFloat {
        return fullWidth * CGFloat(factor)
    }

    var progressColor: Color {
        switch factor {
        case 0.4...1:
            return Color(red: 0.5, green: 0.9, blue: 0.2)
        case 0.2..<0.4:
            return Color(red: 1, green: 0.8, blue: 0)
        default:
            return Color(red: 1, green: 0.3, blue: 0)
        }
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
        CapacityBar(bikesAvailable: 6, spacesAvailable: 2)
    }
}
