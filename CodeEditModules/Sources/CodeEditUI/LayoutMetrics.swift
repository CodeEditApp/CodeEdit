//
//  LayoutMetrics.swift
//  CodeEditUI
//
//  Created by Matthijs Eikelenboom.
//

import CoreGraphics

/// Shared layout constants that multiple features need to agree on.
public enum LayoutMetrics {
    /// The fixed height of the workspace window's status bar, in points.
    /// Taller on macOS 26, matching the Tahoe status bar.
    public static var statusBarHeight: CGFloat {
        if #available(macOS 26, *) {
            37.0
        } else {
            28.0
        }
    }
}
