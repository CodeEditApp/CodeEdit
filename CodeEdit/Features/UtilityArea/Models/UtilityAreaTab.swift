//
//  UtilityAreaTab.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/06/2023.
//

import SwiftUI

enum UtilityAreaTab: WorkspacePanelTab, CaseIterable {
    var id: Self { self }

    case terminal
    case debugConsole
    case output
    case ports

    var title: String {
        switch self {
        case .terminal:
            "Terminal"
        case .debugConsole:
            "Debug Console"
        case .output:
            "Output"
        case .ports:
            "Ports"
        }
    }

    var systemImage: String {
        switch self {
        case .terminal:
            "terminal"
        case .debugConsole:
            "ladybug"
        case .output:
            "list.bullet.indent"
        case .ports:
            "powerplug"
        }
    }

    var body: some View {
        switch self {
        case .terminal:
            UtilityAreaTerminalView()
        case .debugConsole:
            UtilityAreaDebugView()
        case .output:
            UtilityAreaOutputView()
        case .ports:
            UtilityAreaPortsView()
        }
    }
}
