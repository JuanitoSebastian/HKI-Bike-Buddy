//
//  CapacityBar.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 10.2.2021.
//

import SwiftUI
/**
 Displays a given amount as a progress bar.
 - Parameter leftValue: The amount of progress (the value on the left)
 - Parameter rightValue: The amount on the right
 */
struct CapacityBar: View {

    let leftValue: Int
    let rightValue: Int

    /// The factor value is used to calculate the width of the progress bar
    private var factor: Double {
        return Double(leftValue) / Double(rightValue + leftValue)
    }

    /// If bikes are not available a view with only one rectangle is returned. 
    var barToDisplay: AnyView {
        if leftValue > 0 {
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
                            width: progressWidth(fullWidth: geometry.size.width - 2),
                            height: geometry.size.height - 2
                        )
                        .cornerRadius(8)
                        .padding([.leading, .trailing], 1)
                        .foregroundColor(Color("CapacityBarBikesNormal"))
                        .animation(Animation.spring())
                }
            }
        )
    }

    var body: some View {
        barToDisplay
            .frame(height: 15)

    }

    /// Calculates the width of the progress bar
    func progressWidth(fullWidth: CGFloat) -> CGFloat {
        return fullWidth * CGFloat(factor)
    }

}

struct CapacityBar_Previews: PreviewProvider {
    static var previews: some View {
        CapacityBar(leftValue: 10, rightValue: 0)
    }
}
