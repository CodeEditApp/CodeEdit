//
//  Color+Focused.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/25.
//

import SwiftUI

extension Color {
    static var focusedColor: some View {
        ZStack {
            Color.accentColor.opacity(isDarkMode() ? 0.55 : 0.75)
            Color.accentColor.blendMode(.softLight)
        }
        .compositingGroup()
    }

    static var unfocusedColor: Color {
        !isDarkMode() ? .black.opacity(0.11) : .white.opacity(0.12)
    }

    static func isDarkMode() -> Bool {
        NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}
