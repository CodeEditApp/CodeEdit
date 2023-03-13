//
//  ViewCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct ViewCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Show Command Palette") {

            }
            .keyboardShortcut("p")

            Button("Customize Toolbar...") {

            }
        }
    }
}
