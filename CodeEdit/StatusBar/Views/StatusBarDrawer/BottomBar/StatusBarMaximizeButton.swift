//
//  StatusBarMaximizeButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 12/04/2022.
//

import SwiftUI

struct StatusBarMaximizeButton: View {
    @ObservedObject
    private var model: StatusBarViewModel

    init(model: StatusBarViewModel) {
        self.model = model
    }

    var body: some View {
        Button {
            model.isMaximized.toggle()
        } label: {
            Image(systemName: "arrowtriangle.up.square")
                .foregroundColor(model.isMaximized ? .accentColor : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct StatusBarMaximizeButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "~/Developer")!
        StatusBarMaximizeButton(model: StatusBarViewModel(workspaceURL: url))
    }
}
