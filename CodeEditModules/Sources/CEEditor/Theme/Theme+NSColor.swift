//
//  Theme+NSColor.swift
//  CEEditor
//
//  Created by Matthijs Eikelenboom on 15/08/2026.
//

import AppKit
import CodeEditCore
import CodeEditUI

extension Theme.Attributes {
    /// The attribute's color as an AppKit `NSColor`; setting it stores the new value as a hex string.
    ///
    /// Deliberately module-private: `Theme` lives in `CodeEditCore`, which may not import AppKit, and
    /// `CodeEditUI` — which owns the hex conversion — may not import `CodeEditCore`. Each module that
    /// needs a typed color keeps its own adapter over the shared `String`-keyed helper. `CEEditor` is
    /// the only module that reads theme colors as `NSColor`, so this duplicates nothing.
    var nsColor: NSColor {
        get {
            NSColor(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }
}
