//
//  HelpCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/03/2023.
//

import SwiftUI

struct HelpCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .help) {
            Button("What's New in CodeEdit") {

            }

            Button("Release Notes") {
            }

            Button("Report an Issue") {

            }
        }
    }
}
