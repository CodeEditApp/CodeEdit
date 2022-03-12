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
            .windowToolbarStyle(.unified)
            .handlesExternalEvents(matching: ["open"])
        
        DocumentGroup(newDocument: CodeFile()) { file in
            EditorView(text: file.$document.text)
                .environmentObject(appDelegate)
                .navigationTitle(file.fileURL?.lastPathComponent ?? "Unknown")
        }
        .commands {
            SidebarCommands()
        }
            .handlesExternalEvents(matching: ["openFile"])
        
        Settings {
            SettingsView()
        }
    }
}
