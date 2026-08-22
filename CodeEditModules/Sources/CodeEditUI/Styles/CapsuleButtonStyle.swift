//
//  CapsuleButtonStyle.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/3/25.
//

import SwiftUI

public struct CapsuleButtonStyle: ButtonStyle {
    var isActive: Bool?
    var font: Font?
    var width: CGFloat?
    var height: CGFloat?

    public init(isActive: Bool? = nil, font: Font? = nil, size: CGFloat? = nil) {
        self.isActive = isActive
        self.font = font
        self.width = size
        self.height = size
    }

    public init(isActive: Bool? = nil, font: Font? = nil, width: CGFloat?, height: CGFloat?) {
        self.isActive = isActive
        self.font = font
        self.width = width
        self.height = height
    }

    public func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        CapsuleButton(
            configuration: configuration,
            isActive: isActive,
            font: font,
            width: width,
            height: height
        )
    }

    struct CapsuleButton: View {
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

        public init(
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
                .foregroundStyle(
                    isActive
                    ? Color(.white)
                    : Color(.labelColor)
                )
                .frame(width: width, height: height, alignment: .center)
                .contentShape(Capsule())
                .brightness(
                    configuration.isPressed
                    ? colorScheme == .dark
                    ? 0.5
                    : isActive ? -0.25 : -0.75
                    : 0
                )
                .opacity(controlActiveState == .inactive ? 0.5 : 1)
                .background(Capsule().fill(isActive ? Color.accentColor : .clear))
        }
    }
}

public extension ButtonStyle where Self == CapsuleButtonStyle {
    /// A square capsule icon button of `size` on each edge.
    static func capsuleIcon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGFloat? = 24
    ) -> CapsuleButtonStyle {
        return CapsuleButtonStyle(isActive: isActive, font: font, size: size)
    }
    /// A capsule icon button sized to `size`.
    static func capsuleIcon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGSize? = CGSize(width: 24, height: 24)
    ) -> CapsuleButtonStyle {
        return CapsuleButtonStyle(isActive: isActive, font: font, width: size?.width, height: size?.height)
    }
    /// A capsule icon button with independently specified dimensions.
    static func capsuleIcon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) -> CapsuleButtonStyle {
        return CapsuleButtonStyle(isActive: isActive, font: font, width: width, height: height)
    }
    /// A capsule icon button that sizes itself to its content.
    static func capsuleIcon(
        isActive: Bool? = false,
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default)
    ) -> CapsuleButtonStyle {
        return CapsuleButtonStyle(isActive: isActive, font: font)
    }
    /// A capsule icon button with default styling.
    static var capsuleIcon: CapsuleButtonStyle { .init() }
}
