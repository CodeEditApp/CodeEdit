//
//  Theme+Color.swift
//  CodeEditSettings
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

public extension Theme.Attributes {
    var swiftColor: Color {
        get {
            Color(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }

    var nsColor: NSColor {
        get {
            NSColor(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }
}
