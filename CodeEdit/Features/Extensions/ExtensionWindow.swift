//
//  ExtensionWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 31/12/2022.
//

import SwiftUI

struct ExtensionWindow: Scene {
    var body: some Scene {
        Window("Extensions", id: "Extensions") {
            ExtensionWindowContentView()
                .environmentObject(ExtensionDiscovery.shared)
        }
    }

    static func openExtensionWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 460),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        let windowController = NSWindowController(window: window)

        let view = ExtensionWindowContentView()
            .environmentObject(ExtensionDiscovery.shared)

        window.contentView = NSHostingView(rootView: view)
        window.makeKeyAndOrderFront(self)
    }
}
