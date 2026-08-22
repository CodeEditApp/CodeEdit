//
//  GeneratedThemeStrategy.swift
//  CodeEdit
//

import Foundation

/// A color-harmony strategy used to derive syntax colors from the system accent color.
enum GeneratedThemeStrategy: String, CaseIterable, Codable, Hashable, Identifiable {
    case complementary
    case monochromatic
    case analogous
    case triadic
    case tetradic

    var id: Self { self }

    var displayName: String {
        switch self {
        case .complementary:
            "Complementary"
        case .monochromatic:
            "Monochromatic"
        case .analogous:
            "Analogous"
        case .triadic:
            "Triadic"
        case .tetradic:
            "Tetradic"
        }
    }

    /// Hue rotations, expressed as fractions of one full turn.
    var hueOffsets: [CGFloat] {
        switch self {
        case .complementary:
            [0, 0.5]
        case .monochromatic:
            [0]
        case .analogous:
            [0, -1.0 / 12.0, 1.0 / 12.0]
        case .triadic:
            [0, 1.0 / 3.0, 2.0 / 3.0]
        case .tetradic:
            [0, 0.25, 0.5, 0.75]
        }
    }
}
