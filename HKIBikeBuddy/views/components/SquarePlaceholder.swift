//
//  SquarePlaceholder.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 7.4.2021.
//

import SwiftUI

struct SquarePlaceholder: View {

    let timer = Timer.publish(
        every: Double.random(in: 0.9...1.1),
        tolerance: 0.1,
        on: .main,
        in: .common
    ).autoconnect()

    @State var offset: CGFloat = -1 * (UIScreen.main.bounds.width / 2)

    private var backgroundColor: Color {
        Color("SquarePlaceholderBg")
    }

    private var accentColor: Color {
        .white
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.clear)
                .background(
                    ZStack {
                        backgroundColor.ignoresSafeArea()
                        LinearGradient(
                            gradient: Gradient(colors: [backgroundColor, accentColor, backgroundColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .offset(x: offset, y: 0)
                        .animation(Animation.easeInOut(duration: 1))
                    }
                )
        }
        .cornerRadius(10)
        .onReceive(timer) { (_) in
            let width = UIScreen.main.bounds.width / 2
            withAnimation {
                self.offset = self.offset < 0 ? width : -1 * width
            }
        }
    }
}

#if DEBUG
struct SquarePlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        SquarePlaceholder()
    }
}
#endif
