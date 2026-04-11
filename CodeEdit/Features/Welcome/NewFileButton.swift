//
//  NewFileButton.swift
//  CodeEdit
//
//  Created by Giorgi Tchelidze on 07.06.25.
//

import SwiftUI
import Factory
import WelcomeWindow

struct NewFileButton: View {

    var dismissWindow: () -> Void

    var body: some View {
        WelcomeButton(
            iconName: "plus.square",
            title: "Create New File...",
            action: {
                let windowManager = Container.shared.workspaceWindowManager()
                windowManager.newDocumentFromPanel()
                dismissWindow()
            }
        )
    }
}
