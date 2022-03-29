//
//  StatusBarCursorLocationLabel.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

@available(macOS 12, *)
internal struct StatusBarCursorLocationLabel: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Text("Ln \(model.currentLine), Col \(model.currentCol)")
            .font(model.toolbarFont)
            .foregroundStyle(.primary)
            .fixedSize()
            .lineLimit(1)
            .onHover { isHovering($0) }
    }
}
