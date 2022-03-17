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
            break
        case .dark:
            NSApp.appearance = .init(named: .darkAqua)
            break
        case .light:
            NSApp.appearance = .init(named: .aqua)
            break
        }
    }
    
    static let `default` = Appearances.system
    static let storageKey = "appearance"
}
