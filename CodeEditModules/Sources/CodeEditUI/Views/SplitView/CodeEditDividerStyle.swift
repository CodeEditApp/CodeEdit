//
//  CodeEditDividerStyle.swift
//  CodeEditUI
//
//  Created by Khan Winter on 5/30/25.
//

import AppKit

public enum CodeEditDividerStyle: Equatable, Sendable {
    case system(NSSplitView.DividerStyle)
    case editorDivider

    public var customColor: NSColor? {
        switch self {
        case .system:
            return nil
        case .editorDivider:
            return NSColor(name: nil) { appearance in
                if appearance.name == .darkAqua {
                    NSColor.black
                } else {
                    NSColor(white: 203.0 / 255.0, alpha: 1.0)
                }
            }
        }
    }

    public var customThickness: CGFloat? {
        switch self {
        case .system:
            return nil
        case .editorDivider:
            return 3.0
        }
    }
}
