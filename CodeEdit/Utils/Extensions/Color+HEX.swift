//
//  Color+HEX.swift
//  CodeEditModules/CodeEditUtils
//
//  Created by Lukas Pistrol on 23.03.22.
//

import SwiftUI

extension Color {

    /// Initializes a `Color` from a HEX String (e.g.: `#1D2E3F`) and an optional alpha value.
    /// - Parameters:
    ///   - hex: A String of a HEX representation of a color (format: `#1D2E3F`)
    ///   - alpha: A Double indicating the alpha value from `0.0` to `1.0`
    init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int), alpha: alpha)
    }

    /// Initializes a `Color` from an Int (e.g.: `0x1D2E3F`)and an optional alpha value.
    /// - Parameters:
    ///   - hex: An Int of a HEX representation of a color (format: `0x1D2E3F`)
    ///   - alpha: A Double indicating the alpha value from `0.0` to `1.0`
    init(hex: Int, alpha: Double = 1.0) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: alpha)
    }

    /// Returns an Int representing the `Color` in hex format (e.g.: 0x112233)
    var hex: Int {
        guard let components = cgColor?.components, components.count >= 3 else { return 0 }

        let red = lround((Double(components[0]) * 255.0)) << 16
        let green = lround((Double(components[1]) * 255.0)) << 8
        let blue = lround((Double(components[2]) * 255.0))

        return red | green | blue
    }

    /// Returns a HEX String representing the `Color` (e.g.: #112233)
    var hexString: String {
        let color = self.hex

        return "#" + String(format: "%06x", color)
    }

    /// The alpha (opacity) component of the Color (0.0 - 1.0)
    var alphaComponent: Double {
        NSColor(self).alphaComponent
    }
}

extension NSColor {

    /// Initializes a `NSColor` from a HEX String (e.g.: `#1D2E3F`) and an optional alpha value.
    /// - Parameters:
    ///   - hex: A String of a HEX representation of a color (format: `#1D2E3F`)
    ///   - alpha: A Double indicating the alpha value from `0.0` to `1.0`
    convenience init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int), alpha: alpha)
    }

    /// Initializes a `NSColor` from an Int  (e.g.: `0x1D2E3F`)and an optional alpha value.
    /// - Parameters:
    ///   - hex: An Int of a HEX representation of a color (format: `0x1D2E3F`)
    ///   - alpha: A Double indicating the alpha value from `0.0` to `1.0`
    convenience init(hex: Int, alpha: Double = 1.0) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(srgbRed: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, alpha: alpha)
    }

    /// Returns an Int representing the `NSColor` in hex format (e.g.: 0x112233)
    var hex: Int {
        guard let components = cgColor.components, components.count >= 3 else { return 0 }

        let red = lround((Double(components[0]) * 255.0)) << 16
        let green = lround((Double(components[1]) * 255.0)) << 8
        let blue = lround((Double(components[2]) * 255.0))

        return red | green | blue
    }

    /// Returns a HEX String representing the `NSColor` (e.g.: #112233)
    var hexString: String {
        let color = self.hex

        return "#" + String(format: "%06x", color)
    }
}
