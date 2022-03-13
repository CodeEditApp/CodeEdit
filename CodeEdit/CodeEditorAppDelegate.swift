//
//  CodeEditorAppDelegate.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI

class CodeEditorAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let appearanceString = UserDefaults.standard.string(forKey: Appearances.appearanceStorageKey) {
            Appearances(rawValue: appearanceString)?.applyAppearance()
        }
    }
    
    func newProjectURL() -> URL? {
        let dialog = NSOpenPanel()

        dialog.title = "Open Workspace"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            return dialog.url
        } else {
            return nil
        }
    }
}
