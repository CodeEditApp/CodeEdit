//
//  Color+HEX.swift
//  CodeEditUI
//
//  Created by Lukas Pistrol on 23.03.22.
//

import SwiftUI

public extension Color {
    /// Creates a color from a hex string such as `#AABBCC`; surrounding non-alphanumeric characters are ignored.
    init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int), alpha: alpha)
    }

    /// Creates a color in the sRGB color space from a packed `0xRRGGBB` integer and an optional alpha.
    init(hex: Int, alpha: Double = 1.0) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: alpha)
    }

    /// The color's RGB components packed into a single `0xRRGGBB` integer; alpha is not included.
    var hex: Int {
        guard let components = cgColor?.components, components.count >= 3 else { return 0 }
        let red = lround((Double(components[0]) * 255.0)) << 16
        let green = lround((Double(components[1]) * 255.0)) << 8
        let blue = lround((Double(components[2]) * 255.0))
        return red | green | blue
    }

    /// The color formatted as a lowercase web-style hex string, e.g. `#aabbcc`.
    var hexString: String {
        "#" + String(format: "%06x", hex)
    }

    /// The color's alpha (opacity) component, in the range `0...1`.
    var alphaComponent: Double {
        NSColor(self).alphaComponent
    }
}

public extension NSColor {
    /// Creates a color from a hex string such as `#AABBCC`; surrounding non-alphanumeric characters are ignored.
    convenience init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int), alpha: alpha)
    }

    /// Creates a color in the sRGB color space from a packed `0xRRGGBB` integer and an optional alpha.
    convenience init(hex: Int, alpha: Double = 1.0) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(srgbRed: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, alpha: alpha)
    }

    /// The color's RGB components packed into a single `0xRRGGBB` integer; alpha is not included.
    var hex: Int {
        guard let components = cgColor.components, components.count >= 3 else { return 0 }
        let red = lround((Double(components[0]) * 255.0)) << 16
        let green = lround((Double(components[1]) * 255.0)) << 8
        let blue = lround((Double(components[2]) * 255.0))
        return red | green | blue
    }

    /// The color formatted as a lowercase web-style hex string, e.g. `#aabbcc`.
    var hexString: String {
        "#" + String(format: "%06x", hex)
    }
}
