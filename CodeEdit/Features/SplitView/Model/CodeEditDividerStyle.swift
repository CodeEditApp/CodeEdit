//
//  CodeEditDividerStyle.swift
//  CodeEdit
//
//  Created by Khan Winter on 5/30/25.
//

import AppKit

enum CodeEditDividerStyle: Equatable {
    case system(NSSplitView.DividerStyle, color: NSColor? = nil)
    case thick(color: NSColor? = nil)

    var color: NSColor? {
        switch self {
        case .system(_, let color):
            return color
        case .thick(let color):
            return color
        }
    }
}
