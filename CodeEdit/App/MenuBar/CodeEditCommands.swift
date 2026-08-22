//
//  CodeEditCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import CodeEditSettings
import SwiftUI

struct CodeEditCommands: Commands {
    let dependencies: AppDependencies

    /// The settings store, taken from `dependencies` rather than from the environment.
    ///
    /// See ``ViewCommands/settingsStore`` for why: `Commands` content is not part of the view
    /// hierarchy, so `@Environment` — and with it `@AppSettings` — cannot be relied on here. Without
    /// a real store this menu would build with `DefaultSettingsReader`, trapping in debug and showing
    /// the Source Control group unconditionally in release.
    @ObservedObject private var settingsStore: PersistentSettingsStore

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.settingsStore = dependencies.settingsStore
    }

    private var sourceControlIsEnabled: Bool {
        SettingsData(accessor: settingsStore).sourceControl.general.sourceControlIsEnabled
    }

    var body: some Commands {
        Group { // SwiftUI limits to 9 items in an initializer, so we have to group every 9 items.
            MainCommands()
            FileCommands(windowManager: dependencies.workspaceWindowManager)
            ViewCommands(settingsStore: settingsStore)
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
