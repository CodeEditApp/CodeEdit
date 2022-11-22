//
//  StatusBarTabType.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 11.05.22.
//

import Foundation

/// A collection of types describing possible tabs in the Status Bar.
enum StatusBarTabType: String, CaseIterable, Identifiable {
    case terminal
    case debugger
    case output

    var id: String { self.rawValue }
    static var allOptions: [String] {
        StatusBarTabType.allCases.map(\.rawValue.capitalized)
    }
}
