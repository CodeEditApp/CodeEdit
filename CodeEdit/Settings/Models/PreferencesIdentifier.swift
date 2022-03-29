//
//  PreferencesIdentifier.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/23.
//

import Preferences

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let theme = Self("theme")
    static let terminal = Self("terminal")
    static let execution = Self("execution")
    static let `extension` = Self("extension")
}
