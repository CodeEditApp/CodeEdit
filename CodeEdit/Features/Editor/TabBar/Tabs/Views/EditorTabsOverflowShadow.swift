//
//  EditorTabsOverflowShadow.swift
//  CodeEdit
//
//  Created by Austin Condiff on 8/22/23.
//

import SwiftUI

struct EditorTabsOverflowShadow: View {
    var width: CGFloat
    var startPoint: UnitPoint
    var endPoint: UnitPoint

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    var body: some View {
        Rectangle()
            .frame(maxHeight: .infinity)
            .frame(width: width)
            .foregroundColor(.clear)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            Gradient.Stop(color: .black.opacity(0.75), location: 0),
                            Gradient.Stop(color: .black.opacity(0.25), location: 0.5),
                            Gradient.Stop(color: .black.opacity(0), location: 1)
                        ]
                    ),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .opacity(
                    colorScheme == .dark
                    ? activeState == .inactive ? 0.25882353 : 1
                    : activeState == .inactive ? 0.09803922 : 0.25882353
                )
            )
            .allowsHitTesting(false)
    }
}
