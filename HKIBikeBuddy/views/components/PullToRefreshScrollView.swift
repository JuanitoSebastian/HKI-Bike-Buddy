//
//  PullToRefreshScrollView.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 14.4.2021.
//

import SwiftUI

struct PullToRefreshScrollView<Content: View>: View {

    @State var refresh: Refresh = Refresh(started: false, released: false)
    var builder: () -> Content
    let onRelease: () -> Void

    init(
        onRelease: @escaping () -> Void,
        @ViewBuilder builder: @escaping () -> Content
    ) {
        self.builder = builder
        self.onRelease = onRelease
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            GeometryReader { geometry -> AnyView in
                DispatchQueue.main.async {

                    if refresh.startOffset == 0 {
                        refresh.startOffset = geometry.frame(in: .global).minY
                    }

                    refresh.offset = geometry.frame(in: .global).minY

                    if refresh.offset - refresh.startOffset > 80 && !refresh.started {
                        refresh.started = true
                    }

                    if refresh.startOffset == refresh.offset && refresh.started && !refresh.released {
                        withAnimation(Animation.linear) {
                            refresh.released = true
                        }
                        action()
                    }

                    if refresh.startOffset == refresh.offset && refresh.started && refresh.released &&
                        refresh.invalid {
                        refresh.invalid = false
                        action()
                    }
                }
                return AnyView(Color.black.frame(width: 0, height: 0))
            }
            .frame(width: 0, height: 0)

            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                if refresh.started && refresh.released {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .offset(y: -32)
                } else {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(Color("PullToRefreshIcon"))
                        .rotationEffect(.init(degrees: refresh.started ? 180 : 0))
                        .offset(y: -30)
                        .animation(.spring())
                        .opacity(refresh.offset != refresh.startOffset ? 1 : 0)
                }

                VStack {
                    builder()
                }
                .frame(maxWidth: .infinity)
            }
            .offset(y: refresh.released ? 40 : -10)
        }
    }
}

// MARK: - Functions
extension PullToRefreshScrollView {
    private func action() {
        DispatchQueue.main.async {
            withAnimation(Animation.linear) {
                if refresh.startOffset == refresh.offset {
                    onRelease()
                    refresh.released = false
                    refresh.started = false
                } else {
                    refresh.invalid = true
                }
            }
        }
    }
}

struct Refresh {
    var startOffset: CGFloat = 0
    var offset: CGFloat = 0
    var started: Bool
    var released: Bool
    var invalid: Bool = false
}
