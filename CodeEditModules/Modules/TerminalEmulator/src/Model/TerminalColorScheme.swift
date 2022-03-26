//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 26.03.22.
//

import Foundation

public enum TerminalColorScheme: String, CaseIterable, Hashable {
	case auto
	case light
	case dark

	static public let `default` = TerminalColorScheme.auto
	static public let storageKey = "terminalColorScheme"
}
