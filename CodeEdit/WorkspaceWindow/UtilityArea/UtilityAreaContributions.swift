//
//  UtilityAreaContributions.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/08/26.
//

import CodeEditUI
import SwiftUI

struct TerminalUtilityContribution: WorkspacePanelContribution {
    let id = "terminal"
    let title = "Terminal"
    let systemImage = "terminal"
    var content: AnyView { AnyView(UtilityAreaTerminalView()) }
}

struct DebugConsoleUtilityContribution: WorkspacePanelContribution {
    let id = "debugConsole"
    let title = "Debug Console"
    let systemImage = "ladybug"
    var content: AnyView { AnyView(UtilityAreaDebugView()) }
}

struct OutputUtilityContribution: WorkspacePanelContribution {
    let id = "output"
    let title = "Output"
    let systemImage = "list.bullet.indent"
    var content: AnyView { AnyView(UtilityAreaOutputView()) }
}
