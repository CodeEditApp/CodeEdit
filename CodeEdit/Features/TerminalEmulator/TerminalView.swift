//
//  TerminalEmulatorView.swift
//  CodeEditModules/TerminalEmulator
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import SwiftTerm

/// # TerminalEmulatorView
///
/// A terminal emulator view.
///
/// Wraps a `LocalProcessTerminalView` from `SwiftTerm` inside a `NSViewRepresentable`
/// for use in SwiftUI.
///
struct TerminalEmulatorView: NSViewRepresentable {
    @AppSettings(\.terminal)
    var terminalSettings
    @AppSettings(\.textEditing.font)
    var fontSettings
    let emulator: TerminalEmulator

    @StateObject private var themeModel: ThemeModel = .shared

    private var font: NSFont {
        let systemFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .medium)

        if terminalSettings.useTextEditorFont {
            if !fontSettings.customFont {
                return systemFont.withSize(CGFloat(fontSettings.size))
            }
            return NSFont(
                name: fontSettings.name,
                size: CGFloat(fontSettings.size)
            ) ?? systemFont
        }

        if !terminalSettings.font.customFont {
            return systemFont.withSize(CGFloat(terminalSettings.font.size))
        }
        return NSFont(
            name: terminalSettings.font.name,
            size: CGFloat(terminalSettings.font.size)
        ) ?? systemFont
    }

    init(_ emulator: TerminalEmulator) {
        self.emulator = emulator
    }

    private func getTerminalCursor() -> CursorStyle {
            let blink = terminalSettings.cursorBlink
            switch terminalSettings.cursorStyle {
            case .block:
                return blink ? .blinkBlock : .steadyBlock
            case .underline:
                return blink ? .blinkUnderline : .steadyUnderline
            case .bar:
                return blink ? .blinkBar : .steadyBar
            }
    }

    /// Returns true if the `option` key should be treated as the `meta` key.
    private var optionAsMeta: Bool {
        terminalSettings.optionAsMeta
    }

    /// Returns the mapped array of `SwiftTerm.Color` objects of ANSI Colors
    private var colors: [SwiftTerm.Color] {
        if let selectedTheme = Settings[\.theme].matchAppearance && Settings[\.terminal].darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return themeModel.themes[index].terminal.ansiColors.map { color in
                SwiftTerm.Color(hex: color)
            }
        }
        return []
    }

    /// Returns the `cursor` color of the selected theme
    private var cursorColor: NSColor {
        if let selectedTheme = Settings[\.theme].matchAppearance && Settings[\.terminal].darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.cursor.swiftColor)
        }
        return NSColor(.accentColor)
    }

    /// Returns the `selection` color of the selected theme
    private var selectionColor: NSColor {
        if let selectedTheme = Settings[\.theme].matchAppearance && Settings[\.terminal].darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.selection.swiftColor)
        }
        return NSColor(.accentColor)
    }

    /// Returns the `text` color of the selected theme
    private var textColor: NSColor {
        if let selectedTheme = Settings[\.theme].matchAppearance && Settings[\.terminal].darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.text.swiftColor)
        }
        return NSColor(.primary)
    }

    /// Returns the `background` color of the selected theme
    private var backgroundColor: NSColor {
        return .clear
    }

    /// returns a `NSAppearance` based on the user setting of the terminal appearance,
    /// `nil` if app default is not overridden
    private var colorAppearance: NSAppearance? {
        if terminalSettings.darkAppearance {
            return .init(named: .darkAqua)
        }
        return nil
    }

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        // reusing the view means that displaying the same emulator
        // multiple times at once would be an issue
        emulator.nsview
    }

    func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
        // fixes memory leak
        if view.font != font {
            view.font = font
        }
        view.configureNativeColors()
        view.installColors(self.colors)
        view.caretColor = cursorColor
        view.selectedTextBackgroundColor = selectionColor
        view.nativeForegroundColor = textColor
        view.nativeBackgroundColor = terminalSettings.useThemeBackground ? backgroundColor : .clear
        view.optionAsMetaKey = optionAsMeta
        view.cursorStyleChanged(source: view.getTerminal(), newStyle: getTerminalCursor())
        view.appearance = colorAppearance

        view.getTerminal().softReset()
        view.feed(text: "") // send empty character to force colors to be redrawn
    }
}
