//
//  WelcomeWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct WelcomeWindow: Scene {

    var body: some Scene {
        Window("Welcome To CodeEdit", id: "Welcome") {
            ContentView()
                .frame(width: 795, height: 460)
                .task {
                    if let window = NSApp.windows.first { $0.identifier?.rawValue == "Welcome" } {
                        window.standardWindowButton(.closeButton)?.isHidden = true
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                        window.standardWindowButton(.zoomButton)?.isHidden = true
                        window.isMovableByWindowBackground = true
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .keyboardShortcut("1", modifiers: [.command, .shift])
        .windowResizability(.contentSize)
    }

    struct ContentView: View {
        @Environment(\.dismiss) var dismiss
        @Environment(\.openWindow) var openWindow

        var body: some View {
            WelcomeWindowView(shellClient: currentWorld.shellClient) { url, opened in
                if let url = url {
                    CodeEditDocumentController.shared.openDocument(withContentsOf: url, display: true) { doc, _, _ in
                        if doc != nil {
                            opened()
                        }
                    }
                } else {
                    dismiss()
                    CodeEditDocumentController.shared.openDocument(
                        onCompletion: { _, _ in opened() },
                        onCancel: { openWindow(id: "Welcome") }
                    )
                }
            } newDocument: {
                CodeEditDocumentController.shared.newDocument(nil)
            } dismissWindow: {
                dismiss()
            }
        }
    }
}
