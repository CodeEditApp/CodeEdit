//
//  Welcome.swift
//  CodeEdit
//
//  Created by Nazar Rudnyk on 06.06.2022.
//

import SwiftUI
import WelcomeModule

extension WelcomeWindowView {

    /// Helper function which opens welcome view
    /// TODO: Move this to WelcomeModule after CodeEditDocumentController is in separate module
    static func openWelcomeWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 460),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.center()

        let windowController = NSWindowController(window: window)

        window.contentView = NSHostingView(rootView: WelcomeWindowView(
            shellClient: Current.shellClient,
            openDocument: { url, opened in
                if let url = url {
                    CodeEditDocumentController.shared.openDocument(withContentsOf: url, display: true) { doc, _, _ in
                        if doc != nil {
                            opened()
                        }
                    }
                } else {
                    windowController.window?.close()
                    CodeEditDocumentController.shared.openDocument(
                        onCompletion: { _, _ in opened() },
                        onCancel: { WelcomeWindowView.openWelcomeWindow() }
                    )
                }
            },
            newDocument: {
                CodeEditDocumentController.shared.newDocument(nil)
            },
            dismissWindow: {
                windowController.window?.close()
            }
        ))
        window.makeKeyAndOrderFront(self)
    }
}
