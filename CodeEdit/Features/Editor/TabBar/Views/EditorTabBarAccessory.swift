//
//  TabBarAccessory.swift
//  CodeEdit
//
//  Created by Lingxi Li on 4/28/22.
//

import SwiftUI

/// Accessory icon's view for tab bar.
struct EditorTabBarAccessoryIcon: View {
    /// Unifies icon font for tab bar accessories.
    static let iconFont = Font.system(size: 14, weight: .regular, design: .default)

    private let icon: Image
    private let isActive: Bool
    private let action: () -> Void

    init(icon: Image, isActive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.isActive = isActive
        self.action = action
    }

    var body: some View {
        Button(
            action: action,
            label: {
                icon
            }
        )
        .buttonStyle(.icon(isActive: isActive, size: 24))
    }
}
