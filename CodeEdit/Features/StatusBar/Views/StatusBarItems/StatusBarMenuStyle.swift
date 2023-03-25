//
//  StatusBarMenuStyle.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/24/23
//

import SwiftUI
import CodeEditSymbols

struct StatusBarMenuStyle: MenuStyle {
    @Environment(\.controlActiveState)
    private var controlActive

    @Environment(\.colorScheme)
    private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .controlSize(.small)
            .menuStyle(.borderlessButton)
            .opacity(controlActive == .inactive
                ? colorScheme == .dark ? 0.66 : 1
                : colorScheme == .dark ? 0.54 : 0.72)
            .fixedSize()
    }
}

extension MenuStyle where Self == StatusBarMenuStyle {
    static var statusBar: StatusBarMenuStyle { .init() }
}
