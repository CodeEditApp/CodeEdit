//
//  TabBarItemBackground.swift
//  CodeEdit
//
//  Created by Austin Condiff on 1/17/23.
//

import SwiftUI

struct TabBarItemBackground: View {
    var isActive: Bool
    var isPressing: Bool
    var isDragging: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    private var inHoldingState: Bool {
        isPressing || isDragging
    }

    var body: some View {
        ZStack {
            // Content background (visible if active)
            EffectView(.contentBackground)
                .opacity(isActive ? 1 : 0)

            // Accent color (visible if active)
            Color(.controlAccentColor)
                .hueRotation(.degrees(-5))
                .opacity(
                    isActive
                        ? colorScheme == .dark
                             ? activeState == .inactive ? 0.22 : inHoldingState ? 0.33 : 0.26
                             : activeState == .inactive ? 0.1 : inHoldingState ? 0.27 : 0.2
                        : 0
                )

            // Highlight (if in dark mode)
            Color(.white)
                .blendMode(.plusLighter)
                .opacity(
                    colorScheme == .dark
                        ? isActive
                             ? activeState == .inactive ? 0.04 : inHoldingState ? 0.14 : 0.09
                             : isPressing ? 0.05 : 0
                        : 0
                )

            // Dragging color (if not active)
            Color(.unemphasizedSelectedTextBackgroundColor)
                .opacity(isDragging && !isActive ? 0.85 : 0)
        }
    }
}

struct TabBarItemBackground_Previews: PreviewProvider {
    static var previews: some View {
        TabBarItemBackground(isActive: false, isPressing: false, isDragging: false)
    }
}
