//
//  StatusBarClearButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 12/04/2022.
//

import SwiftUI

struct StatusBarClearButton: View {
    @ObservedObject
    private var model: StatusBarViewModel

    init(model: StatusBarViewModel) {
        self.model = model
    }

    var body: some View {
        Button {
            // Clear terminal
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
}

struct StatusBarClearButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "~/Developer")!
        StatusBarClearButton(model: StatusBarViewModel(workspaceURL: url))
    }
}
