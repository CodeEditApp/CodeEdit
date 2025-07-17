//
//  CodeEditCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

struct CodeEditCommands: Commands {
    @AppSettings(\.sourceControl.general.sourceControlIsEnabled)
    private var sourceControlIsEnabled

    var body: some Commands {
        // Group required every 9 elements for backwards compatibility with some SwiftUI and macOS versions.
        Group {
            MainCommands()
            FileCommands()
            ViewCommands()
            FindCommands()
            NavigateCommands()
            if sourceControlIsEnabled { SourceControlCommands() }
            EditorCommands()
            ExtensionCommands()
            WindowCommands()
        }
        HelpCommands()
    }
}
