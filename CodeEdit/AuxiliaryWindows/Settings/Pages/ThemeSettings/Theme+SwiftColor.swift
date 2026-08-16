//
//  Theme+SwiftColor.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/08/2026.
//

import CodeEditCore
import CodeEditUI
import SwiftUI

extension Theme.Attributes {
    /// The attribute's color as a SwiftUI `Color`; setting it stores the new value as a hex string.
    ///
    /// Deliberately app-target-private: `Theme` lives in `CodeEditCore`, which may not import SwiftUI,
    /// and `CodeEditUI` — which owns the hex conversion — may not import `CodeEditCore`. Each module
    /// that needs a typed color keeps its own adapter over the shared `String`-keyed helper. It stays
    /// settable because the theme settings detail view binds `$…swiftColor` straight into pickers.
    var swiftColor: Color {
        get {
            Color(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }
}
