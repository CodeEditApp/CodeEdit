//
//  ExtensionCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 24/03/2023.
//

import SwiftUI
import CodeEditKit

struct ExtensionCommands: Commands {
    @FocusedObject var manager: ExtensionManager?

    @Environment(\.openWindow) var openWindow

    var body: some Commands {
        CommandMenu("Extensions") {
            Button("Open Extensions Window") {
                openWindow(id: SceneID.extensions.rawValue)
            }
        }
    }
}
