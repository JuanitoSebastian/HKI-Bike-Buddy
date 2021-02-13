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
                LinearGradient(gradient: Gradient(colors: [.clear, Color.white]), startPoint: .top, endPoint: .bottom)
                    .opacity(0.2)
            }
        }
        .frame(height: 25)
        .cornerRadius(10)
    }

    func progressWidth(fullWidth: CGFloat) -> CGFloat {
        return fullWidth * CGFloat(factor)
    }

    var progressColor: Color {
        return Color(red: 1.0, green: factor*1, blue: 0.2)
    }

    var factor: Double {
        Double(bikesAvailable) / Double(spacesAvailable + bikesAvailable)
    }

    var factorInvert: Double {
        Double(spacesAvailable) / Double(spacesAvailable + bikesAvailable)
    }
}
