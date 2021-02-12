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
    @State var barFillAmount: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                Rectangle().frame(width: progressWidth(fullWidth: geometry.size.width), height: geometry.size.height)
                    .foregroundColor(progressColor)
                    .animation(.easeInOut)
                HStack {
                    Text("\(bikesAvailable) bikes")
                        .font(.headline)
                    Spacer()
                    Text("\(spacesAvailable) spaces")
                        .font(.headline)
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                LinearGradient(gradient: Gradient(colors: [.clear, Color.white]), startPoint: .top, endPoint: .bottom)
                    .opacity(0.2)
            }
        }
        .frame(height: 25)
        .cornerRadius(10)
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                barFillAmount = bikesAvailable
            }
        })
    }

    func progressWidth(fullWidth: CGFloat) -> CGFloat {
        return fullWidth * CGFloat(factor)
    }

    var progressColor: Color {
        return Color(red: 1.0, green: factor*1, blue: 0.2)
    }

    var factor: Double {
        Double(barFillAmount) / Double(spacesAvailable + bikesAvailable)
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
