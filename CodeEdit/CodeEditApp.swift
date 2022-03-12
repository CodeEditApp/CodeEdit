//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI

@main
struct CodeEditApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: CodeFile()) { file in
            ContentView(workspace: nil, currentDocument: file.$document)
        }.commands {
            SidebarCommands()
        }
    }
}
