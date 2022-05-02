//
//  StatusBarSplitTerminalButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI

internal struct StatusBarSplitTerminalButton: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Button {
            // todo
        } label: {
            Image(systemName: "square.split.2x1")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
}

struct StatusBarSplitTerminalButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "~/Developer")!
        StatusBarSplitTerminalButton(model: StatusBarModel(workspaceURL: url))
    }
}
