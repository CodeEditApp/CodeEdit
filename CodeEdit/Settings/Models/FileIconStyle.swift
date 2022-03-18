//
//  FileIconStyle.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 18.03.22.
//

import Foundation

enum FileIconStyle: String, CaseIterable, Hashable {
	case color
	case monochrome

	static let `default` = FileIconStyle.color
	static let storageKey = "fileIconStyle"
}
