//
//  Appearances.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import SwiftUI

public enum Appearances: String, CaseIterable, Hashable {
    case system
    case light
    case dark

    public func applyAppearance() {
        switch self {
        case .system:
            NSApp.appearance = nil

        case .dark:
            NSApp.appearance = .init(named: .darkAqua)

        case .light:
            NSApp.appearance = .init(named: .aqua)
        }
    }

    public static let `default` = Appearances.system
    public static let storageKey = "appearance"
}
