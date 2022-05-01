//
//  StatusBarBreakpointButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI
import CodeEditSymbols

internal struct StatusBarBreakpointButton: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Button {
            model.isBreakpointEnabled.toggle()
        } label: {
            if model.isBreakpointEnabled {
                Image.breakpoint_fill
                    .foregroundColor(.accentColor)
            } else {
                Image.breakpoint
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct StatusBarBreakpointButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "~/Developer")!
        StatusBarBreakpointButton(model: StatusBarModel(workspaceURL: url))
    }
}
