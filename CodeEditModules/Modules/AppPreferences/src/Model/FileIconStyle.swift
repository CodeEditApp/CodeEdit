//
//  FileIconStyle.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 18.03.22.
//

import Foundation

public enum FileIconStyle: String, CaseIterable, Hashable {
    case color
    case monochrome

    public static let `default` = FileIconStyle.color
    public static let storageKey = "fileIconStyle"
}
