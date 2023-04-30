//
//  StatusBarIndentSelector.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarIndentSelector: View {
    @AppSettings(\.textEditing.defaultTabWidth) var defaultTabWidth

    var body: some View {
        Menu {
            Button {} label: {
                Text("Use Tabs")
            }.disabled(true)

            Button {} label: {
                Text("Use Spaces")
            }.disabled(true)

            Divider()

            Picker("Tab Width", selection: $defaultTabWidth) {
                ForEach(2..<9) { index in
                    Text("\(index) Spaces")
                        .tag(index)
                }
            }
        } label: {
            Text("\(defaultTabWidth) Spaces")
        }
        .menuStyle(StatusBarMenuStyle())
        .onHover { isHovering($0) }
    }
}
