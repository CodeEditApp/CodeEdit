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
    static let iconFont = Font.system(size: 14.5, weight: .regular, design: .default)

    private let icon: Image
    private let active: Bool
    private let action: () -> Void

    init(icon: Image, active: Bool? = false, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
        self.active = active ?? false
    }

    var body: some View {
        Button(
            action: action,
            label: {
                icon
                    .font(StatusBarIcon.iconFont)
                    .foregroundColor(active ? .accentColor : .secondary)
                    .contentShape(Rectangle())
            }
        )
        .buttonStyle(.plain)
    }
}

struct StatusBarIcon_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarIcon(icon: Image(systemName: "square.bottomthird.inset.filled")) {
            print("Clicked")
        }
    }
}
