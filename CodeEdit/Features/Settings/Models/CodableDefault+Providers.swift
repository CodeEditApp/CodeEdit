//
//  CodableDefault+Providers.swift
//  CodeEdit
//
//  Created by CodeEdit Contributors on 07.04.26.
//

import AppKit

// MARK: - Bool Defaults

enum DefaultTrue: DefaultValueProvider {
    static let defaultValue = true
}

enum DefaultFalse: DefaultValueProvider {
    static let defaultValue = false
}

// MARK: - Terminal Defaults

enum DefaultTerminalShell: DefaultValueProvider {
    static let defaultValue = SettingsData.TerminalShell.system
}

enum DefaultTerminalCursorStyle: DefaultValueProvider {
    static let defaultValue = SettingsData.TerminalCursorStyle.block
}

enum DefaultTerminalFont: DefaultValueProvider {
    static let defaultValue = SettingsData.TerminalFont()
}
