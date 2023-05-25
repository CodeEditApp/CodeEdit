//
//  StatusBarTabType.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 11.05.22.
//

import Foundation

enum DebugAreaTab: Hashable, Identifiable {
    case terminal
    case debug
    case output

    var systemImage: String {
        switch self {
        case .terminal:
            return "terminal"
        case .debug:
            return "ladybug"
        case .output:
            return "list.bullet.indent"
        }
    }

    var id: String {
        return title
    }

    var title: String {
        switch self {
        case .terminal:
            return "Terminal"
        case .debug:
            return "Debug Console"
        case .output:
            return "Output"
        }
    }
}
