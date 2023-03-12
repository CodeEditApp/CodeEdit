//
//  CodeEditCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

struct CodeEditCommands: Commands {
    var body: some Commands {
        SidebarCommands()
        TextEditingCommands()
//        FileCommands()
//        MainCommands()
        CommandGroup(after: .windowArrangement) {
            Button("") {}
        }
        CommandGroup(after: .windowSize) {
            Button("") {}
        }
        CommandGroup(after: .windowList) {
            Button("") {}
        }
        CommandGroup(after: .help) {
            EmptyView()
        }
        CommandGroup(replacing: .toolbar) {
            Button("") {}
            
        }
    }
}

struct FileCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .saveItem) {
            Button("New") {

            }
        }
    }
}
