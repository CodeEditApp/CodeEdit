//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI

@main
struct CodeEditApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: CodeEditorAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate)
        }
        .commands {
            SidebarCommands()
        }
        DocumentGroup(newDocument: CodeFile()) { file in
            ContentView(workspace: nil, currentDocument: file.$document)
                .environmentObject(appDelegate)
        }
        .commands {
            SidebarCommands()
        }
            .windowStyle(.hiddenTitleBar)
            .windowToolbarStyle(.unified)
            .handlesExternalEvents(matching: ["open"])
        Settings {
            SettingsView()
        }
    }
}
