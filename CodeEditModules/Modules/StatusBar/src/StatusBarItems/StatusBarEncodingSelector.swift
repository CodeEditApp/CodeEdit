//
//  StatusBarEncodingSelector.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

@available(macOS 12, *)
internal struct StatusBarEncodingSelector: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Menu {
            // UTF 8, ASCII, ...
        } label: {
            Text("UTF 8")
                .font(model.toolbarFont)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { isHovering($0) }
    }
}
