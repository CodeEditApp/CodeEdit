//
//  CodeEditDividerStyle.swift
//  CodeEdit
//
//  Created by Khan Winter on 5/30/25.
//

import AppKit

/// The style of divider used by ``SplitView``.
///
/// To add a new style, add another case to this enum and fill in the ``customColor`` and ``customThickness``
/// variables. When passed to ``SplitView``, the custom styles will be used instead of the default styles. Leave
/// values as `nil` to use default styles.
enum CodeEditDividerStyle: Equatable {
    case system(NSSplitView.DividerStyle)
    case editorDivider

    var customColor: NSColor? {
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

    var customThickness: CGFloat? {
        switch self {
        case .system:
            return nil
        case .editorDivider:
            return 3.0
        }
    }
}
