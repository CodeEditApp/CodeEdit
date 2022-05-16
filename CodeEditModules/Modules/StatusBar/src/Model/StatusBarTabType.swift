//
//  StatusBarTabType.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 11.05.22.
//

import Foundation

/// A collection of types describing possible tabs in the Status Bar.
public enum StatusBarTabType: String, CaseIterable, Identifiable {
    case terminal
    case debugger
    case output

    public var id: String { self.rawValue }
    public static var allOptions: [String] {
        return StatusBarTabType.allCases.map(\.rawValue.capitalized)
    }
}
