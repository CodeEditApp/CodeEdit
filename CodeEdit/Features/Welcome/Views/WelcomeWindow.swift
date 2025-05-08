//
//  WelcomeWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct WelcomeWindow: Scene {
    @ObservedObject var settings = Settings.shared

    var windowContent: some View {
        ContentView()
            .task {
                if let window = NSApp.findWindow(.welcome) {
                    window.standardWindowButton(.closeButton)?.isHidden = true
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    window.isMovableByWindowBackground = true
                }
            }
    }

    var body: some Scene {
        #if swift(>=5.9) // Needed to safely use availability in Scene builder
        if #available(macOS 15, *) {
            return Window("Welcome To CodeEdit", id: SceneID.welcome.rawValue) {
                windowContent
                    .frame(width: 740, height: 460)
            }
            .windowStyle(.plain)
            .windowResizability(.contentSize)
            .defaultLaunchBehavior(.presented)
        } else {
            return Window("Welcome To CodeEdit", id: SceneID.welcome.rawValue) {
                windowContent
                    .frame(width: 740, height: 432)
            }
            .windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)
        }
        #else
        return Window("Welcome To CodeEdit", id: SceneID.welcome.rawValue) {
            windowContent
                .frame(width: 740, height: 432)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }

    struct ContentView: View {
        @Environment(\.dismiss)
        var dismiss
        @Environment(\.openWindow)
        var openWindow

        var body: some View {
            WelcomeWindowView { url, opened in
                if let url {
                    CodeEditDocumentController.shared.openDocument(withContentsOf: url, display: true) { doc, _, _ in
                        if doc != nil {
                            opened()
                        }
                    }
                } else {
                    dismiss()
                    CodeEditDocumentController.shared.openDocument(
                        onCompletion: { _, _ in opened() },
                        onCancel: { openWindow(sceneID: .welcome) }
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
