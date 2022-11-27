//
//  WelcomeWindowView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

struct WelcomeWindowView: View {
    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let newDocument: () -> Void
    private let dismissWindow: () -> Void
    private let shellClient: ShellClient

    init(
        shellClient: ShellClient,
        openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
        newDocument: @escaping () -> Void,
        dismissWindow: @escaping () -> Void
    ) {
        self.shellClient = shellClient
        self.openDocument = openDocument
        self.newDocument = newDocument
        self.dismissWindow = dismissWindow
    }

    var body: some View {
        HStack(spacing: 0) {
            WelcomeView(
                shellClient: shellClient,
                openDocument: openDocument,
                newDocument: newDocument,
                dismissWindow: dismissWindow
            )
            RecentProjectsView(
                openDocument: openDocument,
                dismissWindow: dismissWindow
            )
        }
        .edgesIgnoringSafeArea(.top)
    }

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
