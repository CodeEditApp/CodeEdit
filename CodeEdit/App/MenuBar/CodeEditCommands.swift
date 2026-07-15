//
//  CodeEditCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI
import CodeEditSettings

struct CodeEditCommands: Commands {
    let dependencies: AppDependencies

    @AppSettings(\.sourceControl.general.sourceControlIsEnabled)
    private var sourceControlIsEnabled

    var body: some Commands {
        Group { // SwiftUI limits to 9 items in an initializer, so we have to group every 9 items.
            MainCommands()
            FileCommands(windowManager: dependencies.workspaceWindowManager)
            ViewCommands()
            FindCommands()
            NavigateCommands()
            TasksCommands()
            if sourceControlIsEnabled { SourceControlCommands() }
            EditorCommands()
            ExtensionCommands()
            WindowCommands()
        }
        HelpCommands()
    }
}
