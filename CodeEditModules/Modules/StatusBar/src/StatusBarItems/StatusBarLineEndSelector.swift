//
//  StatusBarLineEndSelector.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

@available(macOS 12, *)
internal struct StatusBarLineEndSelector: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Menu {
            // LF, CRLF
        } label: {
            Text("LF")
                .font(model.toolbarFont)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { isHovering($0) }
    }
}
