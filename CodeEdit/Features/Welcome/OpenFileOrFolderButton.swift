//
//  OpenFileOrFolderButton.swift
//  CodeEdit
//
//  Created by Giorgi Tchelidze on 07.06.25.
//

import SwiftUI
import WelcomeWindow

struct OpenFileOrFolderButton: View {

    @Environment(\.openWindow)
    private var openWindow

    var dismissWindow: () -> Void

    var body: some View {
        WelcomeButton(
            iconName: "folder",
            title: "Open File or Folder...",
            action: {
                @Service var windowManager: WorkspaceWindowManager
                windowManager.openDocumentWithDialog(
                    canChooseFiles: true,
                    canChooseDirectories: true,
                    onDialogPresented: { dismissWindow() },
                    onCancel: { openWindow(id: DefaultSceneID.welcome) }
                )
            }
        )
    }
}
