//
//  StatusBarBreakpointButton.swift
//  
//
//  Created by Stef Kors on 14/04/2022.
//

import SwiftUI

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
                Image("custom.breakpoint.fill")
                    .foregroundColor(.accentColor)
            } else {
                Image("custom.breakpoint")
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
