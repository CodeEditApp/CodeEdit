//
//  Appearances.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import SwiftUI

enum Appearances: String, CaseIterable, Hashable {
    case system
    case light
    case dark

    func applyAppearance() {
        switch self {
        case .system:
            NSApp.appearance = nil

        case .dark:
            NSApp.appearance = .init(named: .darkAqua)

        case .light:
            NSApp.appearance = .init(named: .aqua)
        }
    }

    static let `default` = Appearances.system
    static let storageKey = "appearance"
}
