//
//  CodeEditCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

struct CodeEditCommands: Commands {
    @AppSettings(\.sourceControl.general.enableSourceControl)
    private var enableSourceControl

    var body: some Commands {
        MainCommands()
        FileCommands()
        ViewCommands()
        FindCommands()
        NavigateCommands()
        if enableSourceControl { SourceControlCommands() }
        ExtensionCommands()
        WindowCommands()
        HelpCommands()
    }
}
