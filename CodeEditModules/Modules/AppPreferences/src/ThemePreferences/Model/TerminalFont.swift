//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 23.03.22.
//

import Foundation

public enum TerminalFont: String, CaseIterable, Hashable {
    case systemFont
    case custom

    static public let `default`: TerminalFont = .systemFont
    static public let storageKey = "terminalFontSelection"
}

public enum TerminalFontName {
    static public let `default`: String = "SFMono-Medium"
    static public let storageKey = "terminalFontName"
}

public enum TerminalFontSize {
    static public let `default`: Int = 11
    static public let storageKey = "terminalFontSize"
}
