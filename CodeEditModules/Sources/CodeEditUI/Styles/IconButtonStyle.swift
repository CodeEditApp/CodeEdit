//
//  IconButtonStyle.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/9/23.
//

import SwiftUI

public struct IconButtonStyle: ButtonStyle {
    var isActive: Bool?
    var font: Font?
    var width: CGFloat?
    var height: CGFloat?

    init(isActive: Bool? = nil, font: Font? = nil, size: CGFloat? = nil) {
        self.isActive = isActive
        self.font = font
        self.width = size
        self.height = size
    }

    init(isActive: Bool? = nil, font: Font? = nil, width: CGFloat?, height: CGFloat?) {
        self.isActive = isActive
        self.font = font
        self.width = width
        self.height = height
    }

    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        IconButton(
            configuration: configuration,
            isActive: isActive,
            font: font,
            width: width,
            height: height
        )
    }

    struct IconButton: View {
        @Environment(\.controlActiveState)
        private var controlActiveState
        @Environment(\.isEnabled)
        private var isEnabled: Bool
        @Environment(\.colorScheme)
        private var colorScheme

        let configuration: ButtonStyle.Configuration
        var isActive: Bool
        var font: Font
        var width: CGFloat?
        var height: CGFloat?

        init(
            configuration: ButtonStyle.Configuration,
            isActive: Bool?,
            font: Font?,
            width: CGFloat?,
            height: CGFloat?
        ) {
            self.configuration = configuration
            self.isActive = isActive ?? false
            self.font = font ?? Font.system(size: 14.5, weight: .regular, design: .default)
            self.width = width
            self.height = height
        }

        var body: some View {
            configuration.label
                .font(font)
                .foregroundColor(
                    isActive
                    ? Color(.controlAccentColor)
                    : Color(.secondaryLabelColor)
                )
                .frame(width: width, height: height, alignment: .center)
                .contentShape(Rectangle())
                .brightness(
                    configuration.isPressed
                    ? colorScheme == .dark
                    ? 0.5
                    : isActive ? -0.25 : -0.75
                    : 0
                )
                .opacity(controlActiveState == .inactive ? 0.5 : 1)
                .symbolVariant(isActive ? .fill : .none)
        }
    }
}

public extension ButtonStyle where Self == IconButtonStyle {
    /// An icon button style with a custom font, active state, and fixed square frame of the given side length.
    static func icon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGFloat? = 24
    ) -> IconButtonStyle {
        return IconButtonStyle(isActive: isActive, font: font, size: size)
    }
    /// An icon button style with a custom font, active state, and fixed frame of the given width and height.
    static func icon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGSize? = CGSize(width: 24, height: 24)
    ) -> IconButtonStyle {
        return IconButtonStyle(isActive: isActive, font: font, width: size?.width, height: size?.height)
    }
    /// An icon button with independently specified dimensions.
    static func icon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> IconButtonStyle {
        return IconButtonStyle(isActive: isActive, font: font, width: width, height: height)
    }
    /// An icon button style with a custom font and active state, and no fixed frame.
    static func icon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default)
    ) -> IconButtonStyle {
        return IconButtonStyle(isActive: isActive, font: font)
    }
    /// An icon button style with the default font and no fixed frame.
    static var icon: IconButtonStyle { .init() }
}
