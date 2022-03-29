//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 23.03.22.
//

import SwiftUI

/// Wrapper for storing `Color` objects as 24-bit integer in UserDefaults
public class AnsiColors: ObservableObject {
    //    public static let `default` =
    public static let storageKey: String = "ANSIColors"
    public static let shared: AnsiColors = .init()

    public init() {
        guard let loadColors = UserDefaults.standard.object(forKey: Self.storageKey) as? [Int] else {
            resetDefault()
            return
        }
        self.mappedColors = loadColors
    }

    public func resetDefault() {
        colors.removeAll()
        colors.append(Color(red: 0.000, green: 0.000, blue: 0.000))
        colors.append(Color(red: 0.600, green: 0.000, blue: 0.000))
        colors.append(Color(red: 0.000, green: 0.651, blue: 0.004))
        colors.append(Color(red: 0.600, green: 0.600, blue: 0.000))
        colors.append(Color(red: 0.000, green: 0.031, blue: 0.702))
        colors.append(Color(red: 0.702, green: 0.020, blue: 0.702))
        colors.append(Color(red: 0.000, green: 0.647, blue: 0.702))
        colors.append(Color(red: 0.749, green: 0.749, blue: 0.749))
        colors.append(Color(red: 0.400, green: 0.400, blue: 0.400))
        colors.append(Color(red: 0.902, green: 0.000, blue: 0.004))
        colors.append(Color(red: 0.004, green: 0.851, blue: 0.000))
        colors.append(Color(red: 0.902, green: 0.898, blue: 0.012))
        colors.append(Color(red: 0.000, green: 0.063, blue: 1.000))
        colors.append(Color(red: 0.902, green: 0.035, blue: 0.902))
        colors.append(Color(red: 0.008, green: 0.902, blue: 0.898))
        colors.append(Color(red: 0.902, green: 0.902, blue: 0.902))
    }

    @Published
    public var mappedColors: [Int] = [] {
        didSet {
            UserDefaults.standard.set(mappedColors, forKey: AnsiColors.storageKey)
        }
    }

    public var colors: [Color] {
        get {
            let mapped = self.mappedColors.map { Color(hex: $0) }
            return mapped
        }
        set {
            self.mappedColors = newValue.map { $0.hex }
        }

    }
}

public extension Color {
    init(hex: Int) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: 1)
    }

    var hex: Int {
        guard let components = cgColor?.components, components.count >= 3 else { return 0 }

        let red = Int(components[0] * 255) << 16
        let green = Int(components[1] * 255) << 8
        let blue = Int(components[2] * 255)

        return red | green | blue
    }
}
