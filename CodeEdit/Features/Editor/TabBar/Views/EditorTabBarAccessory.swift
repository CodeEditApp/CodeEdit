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

/// Tab bar accessory area background for native tab bar style.
struct EditorTabBarAccessoryNativeBackground: View {
    enum DividerPosition {
        case none
        case leading
        case trailing
    }

    /// Divider alignment
    private let dividerPosition: Self.DividerPosition

    init(dividerAt: Self.DividerPosition) {
        self.dividerPosition = dividerAt
    }

    private func getAlignment() -> Alignment {
        switch self.dividerPosition {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .leading
        }
    }

    private func getPaddingDirection() -> Edge.Set {
        switch self.dividerPosition {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .leading
        }
    }

    var body: some View {
        ZStack(alignment: getAlignment()) {
            EditorTabBarNativeInactiveBgColor()
                .padding(getPaddingDirection(), dividerPosition == .none ? 0 : 1)
            EditorTabDivider()
                .opacity(dividerPosition == .none ? 0 : 1)
            EditorTabBarTopDivider()
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
