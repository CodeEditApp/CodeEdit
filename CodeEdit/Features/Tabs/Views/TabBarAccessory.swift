//
//  TabBarAccessory.swift
//  CodeEdit
//
//  Created by Lingxi Li on 4/28/22.
//

import SwiftUI

/// Accessory icon's view for tab bar.
struct TabBarAccessoryIcon: View {
    /// Unifies icon font for tab bar accessories.
    private static let iconFont = Font.system(size: 14, weight: .regular, design: .default)

    private let icon: Image
    private let action: () -> Void

    init(icon: Image, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(
            action: action,
            label: {
                icon
                    .font(TabBarAccessoryIcon.iconFont)
                    .frame(height: TabBarView.height - 2)
                    .padding(.horizontal, 4)
                    .contentShape(Rectangle())
            }
        )
    }
}

extension ButtonStyle where Self == MoveButtonStyle {
    static func move(_ edge: Edge, offset: CGFloat = 2.0) -> MoveButtonStyle {
        MoveButtonStyle(edge: edge, value: offset)
    }
}

struct MoveButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) var isEnabled
    
    let edge: Edge
    let value: CGFloat

    var offset: CGSize {
        switch edge {
        case .top:
            return .init(width: 0, height: -value)
        case .leading:
            return .init(width: -value, height: 0)
        case .bottom:
            return .init(width: 0, height: value)
        case .trailing:
            return .init(width: value, height: 0)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(configuration.isPressed ? offset : .zero)
            .animation(.interactiveSpring(), value: configuration.isPressed)
            .brightness(isEnabled ? 0.0 : -0.3)
    }
}

/// Tab bar accessory area background for native tab bar style.
struct TabBarAccessoryNativeBackground: View {
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
            TabBarNativeInactiveBackgroundColor()
                .padding(getPaddingDirection(), dividerPosition == .none ? 0 : 1)
            TabDivider()
                .opacity(dividerPosition == .none ? 0 : 1)
            TabBarTopDivider()
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
