//
//  Color+HEX.swift
//  
//
//  Created by Lukas Pistrol on 23.03.22.
//

import SwiftUI

public extension Color {
    
    /// Initializes a `Color` from a HEX String (e.g.: #112233)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int))
    }

    /// Initializes a `Color` from an Int (e.g.: 0x112233)
    init(hex: Int) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: 1)
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
}

public extension NSColor {

    /// Initializes a `NSColor` from a HEX String (e.g.: #112233)
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int))
    }

    /// Initializes a `NSColor` from an Int (e.g.: 0x112233)
    convenience init(hex: Int) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(srgbRed: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, alpha: 1)
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
