//
//  NSApp+openWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/03/2023.
//

import AppKit
import SwiftUI

extension OpenWindowAction {
    func callAsFunction(sceneID: SceneID) {
        callAsFunction(id: sceneID.rawValue)
    }
}

extension NSApplication {
    func closeWindow(_ id: SceneID) {
        windows.first { $0.identifier?.rawValue == id.rawValue }?.close()
    }

    func closeWindow(_ ids: SceneID...) {
        ids.forEach { id in
            windows.first { $0.identifier?.rawValue == id.rawValue }?.close()
        }
    }

    func findWindow(_ id: SceneID) -> NSWindow? {
        windows.first { $0.identifier?.rawValue == id.rawValue }
    }

    var openSwiftUIWindows: Int {
        NSApp
            .windows
            .compactMap(\.identifier?.rawValue)
            .compactMap { SceneID(rawValue: $0) }
            .count
    }
}
