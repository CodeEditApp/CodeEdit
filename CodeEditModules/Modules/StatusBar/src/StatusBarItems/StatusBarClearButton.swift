//
//  StatusBarClearButton.swift
//  
//
//  Created by Stef Kors on 12/04/2022.
//

import SwiftUI

internal struct StatusBarClearButton: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Button(action: clearTerminal, label: {
            Image(systemName: "trash")
                .foregroundColor(.secondary)
        }).buttonStyle(.plain)
    }

    internal func clearTerminal() {
        // TODO: implement
    }
}

struct StatusBarClearButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "~/Developer")!
        StatusBarClearButton(model: StatusBarModel(workspaceURL: url))
    }
}
