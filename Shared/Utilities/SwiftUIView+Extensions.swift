//
//  SwiftUIView+Extensions.swift
//  AssetCompressor
//
//  Created by Ray Qu on 21/02/22.
//

import SwiftUI

extension View {
    func onPressedGesture(callback: @escaping (Bool) -> Void) -> some View {
        modifier(OnPressedGestureModifier(callback: callback))
    }
}

private struct OnPressedGestureModifier: ViewModifier {
    @State private var tapped = false
    let callback: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { _ in
                    if !self.tapped {
                        self.tapped = true
                        self.callback(true)
                    }
                }
                .onEnded { _ in
                    self.tapped = false
                    self.callback(false)
                })
    }
}
