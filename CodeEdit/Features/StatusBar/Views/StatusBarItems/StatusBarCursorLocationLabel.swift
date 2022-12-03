//
//  StatusBarCursorLocationLabel.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarCursorLocationLabel: View {
    @Environment(\.controlActiveState)
    private var controlActive

    @ObservedObject
    private var model: StatusBarViewModel

    init(model: StatusBarViewModel) {
        self.model = model
    }

    var body: some View {
        Text("Line: \(model.cursorLocation.line)  Col: \(model.cursorLocation.column)")
            .font(model.toolbarFont)
            .foregroundColor(foregroundColor)
            .fixedSize()
            .lineLimit(1)
            .onHover { isHovering($0) }
    }

    private var foregroundColor: Color {
        controlActive == .inactive ? Color(nsColor: .disabledControlTextColor) : .primary
    }
}
