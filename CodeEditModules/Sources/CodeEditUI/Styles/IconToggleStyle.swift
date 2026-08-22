//
//  IconToggleStyle.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/9/23.
//

import SwiftUI

public struct IconToggleStyle: ToggleStyle {
    var font: Font?
    var size: CGSize?

    @State var isPressing = false

    init(font: Font? = nil, size: CGFloat? = nil) {
        self.font = font
        self.size = size == nil ? nil : CGSize(width: size ?? 0, height: size ?? 0)
    }

    init(font: Font? = nil, size: CGSize? = nil) {
        self.font = font
        self.size = size
    }

    init(font: Font? = nil) {
        self.font = font
        self.size = nil
    }

    public func makeBody(configuration: ToggleStyle.Configuration) -> some View {
        Button(
            action: { configuration.isOn.toggle() },
            label: { configuration.label }
        )
        .buttonStyle(.icon(isActive: configuration.isOn, font: font, size: size))
    }
}

public extension ToggleStyle where Self == IconToggleStyle {
    /// An icon toggle style with a custom font and a fixed square frame of the given side length.
    static func icon(
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGFloat? = 24
    ) -> IconToggleStyle {
        return IconToggleStyle(font: font, size: size)
    }
    /// An icon toggle style with a custom font and a fixed frame of the given width and height.
    static func icon(
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGSize? = CGSize(width: 24, height: 24)
    ) -> IconToggleStyle {
        return IconToggleStyle(font: font, size: size)
    }
    /// An icon toggle style with a custom font and no fixed frame.
    static func icon(
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default)
    ) -> IconToggleStyle {
        return IconToggleStyle(font: font)
    }
    /// An icon toggle style with the default font and no fixed frame.
    static var icon: IconToggleStyle { .init() }
}
