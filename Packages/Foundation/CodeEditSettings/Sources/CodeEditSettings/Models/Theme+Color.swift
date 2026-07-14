//
//  Theme+Color.swift
//  CodeEditSettings
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

public extension Theme.Attributes {
    /// The attribute's color as a SwiftUI `Color`; setting it stores the new value as a hex string.
    var swiftColor: Color {
        get {
            Color(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }

    /// The attribute's color as an AppKit `NSColor`; setting it stores the new value as a hex string.
    var nsColor: NSColor {
        get {
            NSColor(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }
}
