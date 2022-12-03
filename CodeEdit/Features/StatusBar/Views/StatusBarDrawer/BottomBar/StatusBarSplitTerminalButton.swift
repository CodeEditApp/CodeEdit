//
//  StatusBarSplitTerminalButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI

struct StatusBarSplitTerminalButton: View {
    @ObservedObject
    private var model: StatusBarViewModel

    init(model: StatusBarViewModel) {
        self.model = model
    }

    var body: some View {
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
        StatusBarSplitTerminalButton(model: StatusBarViewModel(workspaceURL: url))
    }
}
