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
        MainCommands()
        FileCommands()
        ViewCommands()
        FindCommands()
        NavigateCommands()
        if sourceControlIsEnabled { SourceControlCommands() }
        ExtensionCommands()
        WindowCommands()
        HelpCommands()
    }
}
