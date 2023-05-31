//
//  CodeEditCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

struct CodeEditCommands: Commands {

    var body: some Commands {
        MainCommands()
        FileCommands()
        ViewCommands()
        FindCommands()
        NavigateCommands()
        SourceControlCommands()
        WindowCommands()
        HelpCommands()
        ExtensionCommands()
    }
}
