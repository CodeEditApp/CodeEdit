//
//  TerminalShellType.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 22.03.22.
//

import Foundation

public enum TerminalShellType: String, CaseIterable, Hashable {
	case bash
	case zsh
	case auto

	static public let `default` = TerminalShellType.auto
	static public let storageKey = "terminalShellType"
}
