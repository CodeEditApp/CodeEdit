//
//  StatusBarIcon.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/23/23.
//

import SwiftUI

/// Accessory icon view for status bar.
struct StatusBarIcon: View {
    /// Unifies icon font for status bar accessories.
    private let iconFont: Font

    enum IconSize: CGFloat {
        case small = 11
        case medium = 14.5
    }

    private let icon: Image
    private let active: Bool
    private let action: () -> Void

    init(icon: Image, size: IconSize = .medium, active: Bool? = false, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
        self.active = active ?? false
        self.iconFont = Font.system(size: size.rawValue, weight: .regular, design: .default)
    }

    var body: some View {
        Button(
            action: action,
            label: {
                icon
                    .font(iconFont)
                    .contentShape(Rectangle())
            }
        )
        .buttonStyle(StatusBarIconButtonStyle(isActive: active))
    }
}

struct StatusBarIconButtonStyle: ButtonStyle {
    var isActive: Bool = false
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(isActive ? Color.accentColor : Color.secondary)
            .brightness(configuration.isPressed ? 0.5 : 0)
    }
}
