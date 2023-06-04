//
//  StatusBarMaximizeButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 12/04/2022.
//

import SwiftUI

struct StatusBarMaximizeButton: View {
    @EnvironmentObject
    private var model: DebugAreaViewModel

    var body: some View {
        Button {
            model.isMaximized.toggle()
        } label: {
            Image(systemName: "arrowtriangle.up.square")
                .foregroundColor(model.isMaximized ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}
