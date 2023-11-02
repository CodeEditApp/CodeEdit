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

struct IconButtonStyle: ButtonStyle {
    var isActive: Bool?
    var font: Font?
    var size: CGSize?

    init() {
        self.isActive = nil
        self.font = nil
        self.size = nil
    }

    init(isActive: Bool? = nil, font: Font? = nil, size: CGFloat? = nil) {
        self.isActive = isActive
        self.font = font
        self.size = size == nil ? nil : CGSize(width: size ?? 0, height: size ?? 0)
    }

    init(isActive: Bool? = nil, font: Font? = nil, size: CGSize? = nil) {
        self.isActive = isActive
        self.font = font
        self.size = size
    }

    init(isActive: Bool? = nil, font: Font? = nil) {
        self.isActive = isActive
        self.font = font
        self.size = nil
    }

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        IconButton(
            configuration: configuration,
            isActive: isActive,
            font: font,
            size: size
        )
    }

    struct IconButton: View {
        let configuration: ButtonStyle.Configuration
        var isActive: Bool
        var font: Font
        var size: CGSize?
        @Environment(\.isEnabled)
        private var isEnabled: Bool
        @Environment(\.colorScheme)
        private var colorScheme

        init(configuration: ButtonStyle.Configuration, isActive: Bool?, font: Font?, size: CGFloat?) {
            self.configuration = configuration
            self.isActive = isActive ?? false
            self.font = font ?? Font.system(size: 14.5, weight: .regular, design: .default)
            self.size = size == nil ? nil : CGSize(width: size ?? 0, height: size ?? 0)
        }

        init(configuration: ButtonStyle.Configuration, isActive: Bool?, font: Font?, size: CGSize?) {
            self.configuration = configuration
            self.isActive = isActive ?? false
            self.font = font ?? Font.system(size: 14.5, weight: .regular, design: .default)
            self.size = size ?? nil
        }

        init(configuration: ButtonStyle.Configuration, isActive: Bool?, font: Font?) {
            self.configuration = configuration
            self.isActive = isActive ?? false
            self.font = font ?? Font.system(size: 14.5, weight: .regular, design: .default)
            self.size = nil
        }

        var body: some View {
            configuration.label
                .font(font)
                .foregroundColor(
                    isActive
                        ? Color(.controlAccentColor)
                        : Color(.secondaryLabelColor)
                )
                .frame(width: size?.width, height: size?.height, alignment: .center)
                .contentShape(Rectangle())
                .brightness(
                    configuration.isPressed
                        ? colorScheme == .dark
                            ? 0.5
                            : isActive ? -0.25 : -0.75
                        : 0
                )
        }
    }
}

extension ButtonStyle where Self == IconButtonStyle {
    static func icon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGFloat? = 24
    ) -> IconButtonStyle {
        return IconButtonStyle(isActive: isActive, font: font, size: size)
    }
    static func icon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGSize? = CGSize(width: 24, height: 24)
    ) -> IconButtonStyle {
        return IconButtonStyle(isActive: isActive, font: font, size: size)
    }
    static func icon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default)
    ) -> IconButtonStyle {
        return IconButtonStyle(isActive: isActive, font: font)
    }
    static var icon: IconButtonStyle { .init() }
}

struct StatusBarIcon_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarIcon(icon: Image(systemName: "square.bottomthird.inset.filled")) {
            print("Clicked")
        }
    }
}
