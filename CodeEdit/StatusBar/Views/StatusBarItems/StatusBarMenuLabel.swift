//
//  StatusBarMenuLabel.swift
//  CodeEditModules/StatusBar
//
//  Created by Axel Zuziak on 24.04.2022
//

import SwiftUI
import CodeEditSymbols

/// A view that displays Text with custom chevron up/down symbol
struct StatusBarMenuLabel: View {
    private let text: String

    @ObservedObject
    private var model: StatusBarViewModel

    init(_ text: String, model: StatusBarViewModel) {
        self.text = text
        self.model = model
    }

    var body: some View {
        Text(text + "  ")
            .font(model.toolbarFont) +
        Text(Image.customChevronUpChevronDown)
            .font(model.toolbarFont)
    }
}
