//
//  StatusBarEncodingSelector.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarEncodingSelector: View {
    @ObservedObject
    private var model: StatusBarViewModel

    init(model: StatusBarViewModel) {
        self.model = model
    }

    var body: some View {
        Menu {
            // UTF 8, ASCII, ...
        } label: {
            StatusBarMenuLabel("UTF 8", model: model)
        }
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { isHovering($0) }
    }
}
