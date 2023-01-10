//
//  WelcomeWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/01/2023.
//

import SwiftUI
import WindowManagement

struct WelcomeWindow: Scene {

    var body: some Scene {
        Window("Welcome", id: "WelcomeWindow") {
            WelcomeWindowView(
                shellClient: currentWorld.shellClient,
                openDocument: { url, opened in
                    if let url = url {
                        CodeEditDocumentController.shared.openDocument(withContentsOf: url, display: true) { doc, _, _ in
                            if doc != nil {
                                opened()
                            }
                        }
                    } else {
                        //                        windowController.window?.close()
                        NSApp.windows.first {
                            $0.identifier?.rawValue == "WelcomeWindow"
                        }?.close()
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
                    NSApp.windows.first {
                        $0.identifier?.rawValue == "WelcomeWindow"
                    }?.close()
                }
            )
            .edgesIgnoringSafeArea(.all)
            .frame(height: 460)
            .fixedSize()
        }
        .register("WelcomeWindow")
        .movableByBackground(true)
        .styleMask([.fullSizeContentView])
        .collectionBehavior([.canJoinAllSpaces])
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
