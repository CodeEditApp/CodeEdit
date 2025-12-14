//
//  NewFileButton.swift
//  CodeEdit
//
//  Created by Giorgi Tchelidze on 07.06.25.
//

import SwiftUI
import WelcomeWindow

struct NewFileButton: View {

    var dismissWindow: () -> Void

    var body: some View {
        WelcomeButton(
            iconName: "plus.square",
            title: "Create New File...",
            action: {
                let documentController = CodeEditDocumentControllerProvider.sharedDocumentController()
                documentController.createAndOpenNewDocument(onCompletion: { dismissWindow() })
            }
        )
    }
}

private enum CodeEditDocumentControllerProvider {
    static func sharedDocumentController() -> CodeEditDocumentController {
        if let typed = NSDocumentController.shared as? CodeEditDocumentController {
            return typed
        }
        // Fall back to our own singleton instance without mutating the system `shared`
        struct Holder {
            static let instance = CodeEditDocumentController()
        }
        return Holder.instance
    }
}
