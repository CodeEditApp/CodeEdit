//
//  SettingsGeneratedThemeTests.swift
//  CodeEditTests
//

import AppKit
import XCTest
@testable import CodeEdit

final class SettingsGeneratedThemeTests: XCTestCase {
    func testLegacyThemeSettingsUseGenerationDefaults() throws {
        let settings = try JSONDecoder().decode(
            SettingsData.ThemeSettings.self,
            from: Data("{}".utf8)
        )

        XCTAssertFalse(settings.automaticallyGenerateTheme)
        XCTAssertEqual(settings.generatedThemeStrategy, .analogous)
    }

    func testGeneratedThemeSettingsRoundTrip() throws {
        for strategy in GeneratedThemeStrategy.allCases {
            var settings = SettingsData.ThemeSettings()
            settings.automaticallyGenerateTheme = true
            settings.generatedThemeStrategy = strategy

            let data = try JSONEncoder().encode(settings)
            let decodedSettings = try JSONDecoder().decode(SettingsData.ThemeSettings.self, from: data)

            XCTAssertTrue(decodedSettings.automaticallyGenerateTheme)
            XCTAssertEqual(decodedSettings.generatedThemeStrategy, strategy)
        }
    }

    func testGeneratedThemeRequiresOpaqueEditorBackground() {
        var settings = SettingsData.ThemeSettings()
        settings.useThemeBackground = false

        XCTAssertFalse(settings.useThemeBackgroundInEditor)

        settings.automaticallyGenerateTheme = true

        XCTAssertTrue(settings.useThemeBackgroundInEditor)
    }

    func testStrategiesGenerateExpectedHueHarmonies() {
        let seedHue: CGFloat = 0.02
        let seedColor = NSColor(calibratedHue: seedHue, saturation: 0.6, brightness: 0.9, alpha: 1)
        let backgroundColor = NSColor.black
        let expectedOffsets: [GeneratedThemeStrategy: [CGFloat]] = [
            .complementary: [0, 0.5],
            .monochromatic: [0],
            .analogous: [0, -1.0 / 12.0, 1.0 / 12.0],
            .triadic: [0, 1.0 / 3.0, 2.0 / 3.0],
            .tetradic: [0, 0.25, 0.5, 0.75]
        ]

        for strategy in GeneratedThemeStrategy.allCases {
            let colors = GeneratedThemeGenerator.syntaxColors(
                seedColor: seedColor,
                backgroundColor: backgroundColor,
                appearance: .dark,
                strategy: strategy
            )
            let offsets = expectedOffsets[strategy, default: []]

            for (index, color) in colors.enumerated() {
                let offset = offsets[index % offsets.count]
                XCTAssertEqual(
                    hue(of: color),
                    wrappedHue(seedHue + offset),
                    accuracy: 0.02,
                    "Unexpected hue for \(strategy.displayName)"
                )
            }
        }
    }

    func testEveryStrategyMeetsSyntaxContrastInLightAndDarkThemes() {
        let seedColor = NSColor(srgbRed: 0.12, green: 0.48, blue: 0.92, alpha: 1)
        let backgrounds: [(Theme.ThemeType, NSColor)] = [
            (.light, NSColor(hex: "#FFFFFF")),
            (.dark, NSColor(hex: "#292A30"))
        ]

        for strategy in GeneratedThemeStrategy.allCases {
            for (appearance, backgroundColor) in backgrounds {
                let generatedTheme = GeneratedThemeGenerator.generate(
                    from: makeTheme(appearance: appearance, background: backgroundColor.hexString),
                    seedColor: seedColor,
                    strategy: strategy
                )
                let colors = syntaxAttributes(from: generatedTheme).map(\.nsColor)

                XCTAssertEqual(colors.count, 10)
                for color in colors {
                    XCTAssertGreaterThanOrEqual(
                        GeneratedThemeGenerator.contrastRatio(between: color, and: backgroundColor),
                        GeneratedThemeGenerator.minimumSyntaxContrast
                    )
                }
            }
        }
    }

    func testGraphiteAccentProducesAReadableDeliberateGrayPalette() {
        let backgroundColor = NSColor(hex: "#292A30")
        let colors = GeneratedThemeGenerator.syntaxColors(
            seedColor: NSColor(white: 0.55, alpha: 1),
            backgroundColor: backgroundColor,
            appearance: .dark,
            strategy: .tetradic
        )

        let resolvedColors = colors.compactMap { $0.usingColorSpace(.sRGB) }
        XCTAssertEqual(resolvedColors.count, 10)
        XCTAssertGreaterThan(Set(resolvedColors.map { Int(round($0.redComponent * 255)) }).count, 3)
        for color in resolvedColors {
            XCTAssertEqual(color.redComponent, color.greenComponent, accuracy: 0.001)
            XCTAssertEqual(color.greenComponent, color.blueComponent, accuracy: 0.001)
            XCTAssertGreaterThanOrEqual(
                GeneratedThemeGenerator.contrastRatio(between: color, and: backgroundColor),
                GeneratedThemeGenerator.minimumSyntaxContrast
            )
        }
    }

    func testGenerationPreservesBaseThemeAndTerminalSemantics() {
        let baseTheme = makeTheme(appearance: .light, background: "#FFFFFF")
        let generatedTheme = GeneratedThemeGenerator.generate(
            from: baseTheme,
            seedColor: NSColor.systemYellow,
            strategy: .triadic
        )

        XCTAssertEqual(generatedTheme.appearance, baseTheme.appearance)
        XCTAssertEqual(generatedTheme.editor.background, baseTheme.editor.background)
        XCTAssertEqual(generatedTheme.editor.text, baseTheme.editor.text)
        XCTAssertEqual(generatedTheme.terminal, baseTheme.terminal)
        XCTAssertEqual(generatedTheme.editor.keywords.bold, baseTheme.editor.keywords.bold)
        XCTAssertEqual(generatedTheme.editor.comments.italic, baseTheme.editor.comments.italic)
        XCTAssertNotEqual(generatedTheme.editor.keywords.color, baseTheme.editor.keywords.color)
        XCTAssertNil(generatedTheme.fileURL)
        XCTAssertFalse(generatedTheme.isBundled)
        XCTAssertGreaterThanOrEqual(
            GeneratedThemeGenerator.contrastRatio(
                between: generatedTheme.editor.insertionPoint.nsColor,
                and: generatedTheme.editor.background.nsColor
            ),
            3.0
        )

        for attributes in syntaxAttributes(from: generatedTheme) {
            XCTAssertGreaterThanOrEqual(
                GeneratedThemeGenerator.contrastRatio(
                    between: attributes.nsColor,
                    and: generatedTheme.editor.background.nsColor
                ),
                GeneratedThemeGenerator.minimumSyntaxContrast
            )
        }
    }

    func testGenerationIsDeterministic() {
        let baseTheme = makeTheme(appearance: .light, background: "#FFFFFF")
        let seedColor = NSColor(srgbRed: 0.82, green: 0.18, blue: 0.45, alpha: 1)

        let firstTheme = GeneratedThemeGenerator.generate(
            from: baseTheme,
            seedColor: seedColor,
            strategy: .analogous
        )
        let secondTheme = GeneratedThemeGenerator.generate(
            from: baseTheme,
            seedColor: seedColor,
            strategy: .analogous
        )

        XCTAssertEqual(firstTheme.editor, secondTheme.editor)
        XCTAssertEqual(firstTheme.terminal, secondTheme.terminal)
        XCTAssertEqual(firstTheme.name, secondTheme.name)
    }
}

private extension SettingsGeneratedThemeTests {
    func hue(of color: NSColor) -> CGFloat {
        let color = color.usingColorSpace(.sRGB) ?? color
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return hue
    }

    func wrappedHue(_ hue: CGFloat) -> CGFloat {
        let remainder = hue.truncatingRemainder(dividingBy: 1)
        return remainder < 0 ? remainder + 1 : remainder
    }

    func syntaxAttributes(from theme: Theme) -> [Theme.Attributes] {
        [
            theme.editor.keywords,
            theme.editor.commands,
            theme.editor.types,
            theme.editor.attributes,
            theme.editor.variables,
            theme.editor.values,
            theme.editor.numbers,
            theme.editor.strings,
            theme.editor.characters,
            theme.editor.comments
        ]
    }

    func makeTheme(appearance: Theme.ThemeType, background: String) -> Theme {
        return Theme(
            editor: makeEditorColors(appearance: appearance, background: background),
            terminal: makeTerminalColors(appearance: appearance, background: background),
            author: "Test",
            license: "MIT",
            metadataDescription: "Test theme",
            distributionURL: "",
            isBundled: true,
            name: "test.\(appearance.rawValue)",
            displayName: "Test \(appearance.rawValue)",
            appearance: appearance,
            version: "1.0.0"
        )
    }

    func makeEditorColors(
        appearance: Theme.ThemeType,
        background: String
    ) -> Theme.EditorColors {
        let foreground = Theme.Attributes(color: appearance == .dark ? "#FFFFFF" : "#000000")
        let muted = Theme.Attributes(color: appearance == .dark ? "#A0A0A0" : "#555555")
        let accent = Theme.Attributes(color: "#007AFF")
        let syntax = Theme.Attributes(color: "#FF0000")
        let boldSyntax = Theme.Attributes(color: "#FF0000", bold: true)
        let italicSyntax = Theme.Attributes(color: "#888888", italic: true)
        let background = Theme.Attributes(color: background)

        return Theme.EditorColors(
            text: foreground,
            insertionPoint: accent,
            invisibles: muted,
            background: background,
            lineHighlight: background,
            selection: muted,
            keywords: boldSyntax,
            commands: syntax,
            types: syntax,
            attributes: syntax,
            variables: syntax,
            values: syntax,
            numbers: syntax,
            strings: syntax,
            characters: syntax,
            comments: italicSyntax
        )
    }

    func makeTerminalColors(
        appearance: Theme.ThemeType,
        background: String
    ) -> Theme.TerminalColors {
        let foreground = Theme.Attributes(color: appearance == .dark ? "#FFFFFF" : "#000000")
        let muted = Theme.Attributes(color: appearance == .dark ? "#A0A0A0" : "#555555")
        let syntax = Theme.Attributes(color: "#FF0000")
        let background = Theme.Attributes(color: background)

        return Theme.TerminalColors(
            text: foreground,
            boldText: foreground,
            cursor: foreground,
            background: background,
            selection: muted,
            black: muted,
            red: syntax,
            green: syntax,
            yellow: syntax,
            blue: syntax,
            magenta: syntax,
            cyan: syntax,
            white: foreground,
            brightBlack: muted,
            brightRed: syntax,
            brightGreen: syntax,
            brightYellow: syntax,
            brightBlue: syntax,
            brightMagenta: syntax,
            brightCyan: syntax,
            brightWhite: foreground
        )
    }
}
