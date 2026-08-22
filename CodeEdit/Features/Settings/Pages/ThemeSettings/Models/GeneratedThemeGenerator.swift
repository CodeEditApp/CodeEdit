//
//  GeneratedThemeGenerator.swift
//  CodeEdit
//

import AppKit

/// Generates a transient, accessible syntax palette from a seed color.
enum GeneratedThemeGenerator {
    static let minimumSyntaxContrast: CGFloat = 4.5

    private static let darkBrightness: [CGFloat] = [
        0.90, 0.78, 1.00, 0.70, 0.85, 0.75, 0.95, 0.66, 0.81, 0.72
    ]
    private static let lightBrightness: [CGFloat] = [
        0.55, 0.45, 0.62, 0.38, 0.50, 0.42, 0.58, 0.35, 0.48, 0.40
    ]
    private static let saturationFactors: [CGFloat] = [
        1.00, 0.82, 0.94, 0.68, 0.88, 0.74, 0.97, 0.62, 0.84, 0.70
    ]
    private static let darkGrayBrightness: [CGFloat] = [
        0.86, 0.72, 0.94, 0.64, 0.80, 0.69, 0.90, 0.60, 0.76, 0.83
    ]
    private static let lightGrayBrightness: [CGFloat] = [
        0.28, 0.36, 0.20, 0.42, 0.32, 0.24, 0.39, 0.17, 0.45, 0.30
    ]

    /// Creates a generated theme by replacing only the editor's syntax palette.
    /// The base theme's primary text, background, styling, and terminal colors are preserved.
    static func generate(
        from baseTheme: Theme,
        seedColor: NSColor,
        strategy: GeneratedThemeStrategy
    ) -> Theme {
        var generatedTheme = baseTheme
        let syntaxColors = syntaxColors(
            seedColor: seedColor,
            backgroundColor: baseTheme.editor.background.nsColor,
            appearance: baseTheme.appearance,
            strategy: strategy
        )

        generatedTheme.editor.keywords.color = hexString(for: syntaxColors[0])
        generatedTheme.editor.commands.color = hexString(for: syntaxColors[1])
        generatedTheme.editor.types.color = hexString(for: syntaxColors[2])
        generatedTheme.editor.attributes.color = hexString(for: syntaxColors[3])
        generatedTheme.editor.variables.color = hexString(for: syntaxColors[4])
        generatedTheme.editor.values.color = hexString(for: syntaxColors[5])
        generatedTheme.editor.numbers.color = hexString(for: syntaxColors[6])
        generatedTheme.editor.strings.color = hexString(for: syntaxColors[7])
        generatedTheme.editor.characters.color = hexString(for: syntaxColors[8])
        generatedTheme.editor.comments.color = hexString(for: syntaxColors[9])

        let insertionPoint = colorEnsuringContrast(
            resolvedSRGB(seedColor),
            against: resolvedSRGB(baseTheme.editor.background.nsColor),
            minimumRatio: 3.05
        )
        generatedTheme.editor.insertionPoint.color = hexString(for: insertionPoint)

        generatedTheme.metadataDescription = "Generated from the macOS system accent color using a "
            + "\(strategy.displayName.lowercased()) color harmony."
        generatedTheme.isBundled = false
        generatedTheme.fileURL = nil
        generatedTheme.name = "generated.system-accent.\(strategy.rawValue).\(baseTheme.appearance.rawValue)"
        generatedTheme.displayName = "System Accent — \(strategy.displayName)"

        return generatedTheme
    }

    /// Resolves the user's dynamic accent color for a specific appearance into sRGB.
    /// AppKit applies Desktop Tinting while rendering materials, but does not expose that tint as a color value.
    static func systemAccentColor(for appearance: Theme.ThemeType) -> NSColor {
        let appearanceName: NSAppearance.Name = appearance == .dark ? .darkAqua : .aqua
        guard let drawingAppearance = NSAppearance(named: appearanceName) else {
            return resolvedSRGB(.systemBlue)
        }

        var accentColor = NSColor.systemBlue
        drawingAppearance.performAsCurrentDrawingAppearance {
            accentColor = resolvedSRGB(.controlAccentColor)
        }
        return accentColor
    }

    /// Produces ten syntax colors with a readable contrast ratio against the supplied background.
    static func syntaxColors(
        seedColor: NSColor,
        backgroundColor: NSColor,
        appearance: Theme.ThemeType,
        strategy: GeneratedThemeStrategy
    ) -> [NSColor] {
        let seed = resolvedSRGB(seedColor)
        let background = resolvedSRGB(backgroundColor)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        seed.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)

        if saturation < 0.08 {
            let brightnessValues = appearance == .dark ? darkGrayBrightness : lightGrayBrightness
            return brightnessValues.map {
                colorEnsuringContrast(
                    NSColor(srgbRed: $0, green: $0, blue: $0, alpha: 1),
                    against: background,
                    minimumRatio: minimumSyntaxContrast + 0.05
                )
            }
        }

        let brightnessValues = appearance == .dark ? darkBrightness : lightBrightness
        let baseSaturation = max(saturation, 0.55)

        return (0..<10).map { index in
            let offsets = strategy.hueOffsets
            let offset = offsets[index % offsets.count]
            let variant = index / offsets.count
            let rotatedHue = wrappedHue(hue + offset)
            let adjustedSaturation = clamped(
                baseSaturation * saturationFactors[variant % saturationFactors.count]
            )
            let candidate = NSColor(
                calibratedHue: rotatedHue,
                saturation: adjustedSaturation,
                brightness: brightnessValues[variant % brightnessValues.count],
                alpha: 1
            )

            return colorEnsuringContrast(
                resolvedSRGB(candidate),
                against: background,
                minimumRatio: minimumSyntaxContrast + 0.05
            )
        }
    }

    static func contrastRatio(between firstColor: NSColor, and secondColor: NSColor) -> CGFloat {
        let firstLuminance = relativeLuminance(of: resolvedSRGB(firstColor))
        let secondLuminance = relativeLuminance(of: resolvedSRGB(secondColor))
        let lighter = max(firstLuminance, secondLuminance)
        let darker = min(firstLuminance, secondLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }
}

private extension GeneratedThemeGenerator {
    static func resolvedSRGB(_ color: NSColor) -> NSColor {
        color.usingColorSpace(.sRGB) ?? NSColor(srgbRed: 0, green: 0.478, blue: 1, alpha: 1)
    }

    static func hexString(for color: NSColor) -> String {
        let color = resolvedSRGB(color)
        let red = Int(round(clamped(color.redComponent) * 255))
        let green = Int(round(clamped(color.greenComponent) * 255))
        let blue = Int(round(clamped(color.blueComponent) * 255))
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    static func wrappedHue(_ hue: CGFloat) -> CGFloat {
        let remainder = hue.truncatingRemainder(dividingBy: 1)
        return remainder < 0 ? remainder + 1 : remainder
    }

    static func clamped(_ value: CGFloat) -> CGFloat {
        min(max(value, 0), 1)
    }

    static func colorEnsuringContrast(
        _ color: NSColor,
        against background: NSColor,
        minimumRatio: CGFloat
    ) -> NSColor {
        guard contrastRatio(between: color, and: background) < minimumRatio else {
            return color
        }

        let black = NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        let white = NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        let target = contrastRatio(between: black, and: background)
            > contrastRatio(between: white, and: background) ? black : white

        var lowerBound: CGFloat = 0
        var upperBound: CGFloat = 1
        for _ in 0..<24 {
            let fraction = (lowerBound + upperBound) / 2
            let mixedColor = mix(color, with: target, fraction: fraction)
            if contrastRatio(between: mixedColor, and: background) >= minimumRatio {
                upperBound = fraction
            } else {
                lowerBound = fraction
            }
        }
        return mix(color, with: target, fraction: upperBound)
    }

    static func mix(_ color: NSColor, with target: NSColor, fraction: CGFloat) -> NSColor {
        let color = resolvedSRGB(color)
        let target = resolvedSRGB(target)
        return NSColor(
            srgbRed: color.redComponent + ((target.redComponent - color.redComponent) * fraction),
            green: color.greenComponent + ((target.greenComponent - color.greenComponent) * fraction),
            blue: color.blueComponent + ((target.blueComponent - color.blueComponent) * fraction),
            alpha: 1
        )
    }

    static func relativeLuminance(of color: NSColor) -> CGFloat {
        func linearized(_ component: CGFloat) -> CGFloat {
            component <= 0.04045
                ? component / 12.92
                : pow((component + 0.055) / 1.055, 2.4)
        }

        return (0.2126 * linearized(color.redComponent))
            + (0.7152 * linearized(color.greenComponent))
            + (0.0722 * linearized(color.blueComponent))
    }
}
