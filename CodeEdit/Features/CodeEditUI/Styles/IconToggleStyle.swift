//
//  IconToggleStyle.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/9/23.
//

import SwiftUI

struct IconToggleStyle: ToggleStyle {
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

    func makeBody(configuration: ToggleStyle.Configuration) -> some View {
        Button(
            action: { configuration.isOn.toggle() },
            label: { configuration.label }
        )
        .buttonStyle(.icon(isActive: configuration.isOn, font: font, size: size))
    }
}

extension ToggleStyle where Self == IconToggleStyle {
    static func icon(
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGFloat? = 24
    ) -> IconToggleStyle {
        return IconToggleStyle(font: font, size: size)
    }
    static func icon(
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default),
        size: CGSize? = CGSize(width: 24, height: 24)
    ) -> IconToggleStyle {
        return IconToggleStyle(font: font, size: size)
    }
    static func icon(
        font: Font? = Font.system(size: 14.5, weight: .regular, design: .default)
    ) -> IconToggleStyle {
        return IconToggleStyle(font: font)
    }
    static var icon: IconToggleStyle { .init() }
}
