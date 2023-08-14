//
//  CodeFileView.swift
//  CodeEditModules/CodeFile
//
//  Created by Marco Carnevali on 17/03/22.
//

import Foundation
import SwiftUI
import CodeEditTextView
import CodeEditLanguages
import Combine

/// CodeFileView is just a wrapper of the `CodeEditor` dependency
struct CodeFileView: View {
    @ObservedObject private var codeFile: CodeFileDocument

    @AppSettings(\.textEditing.defaultTabWidth)
    var defaultTabWidth
    @AppSettings(\.textEditing.indentOption)
    var indentOption
    @AppSettings(\.textEditing.lineHeightMultiple)
    var lineHeightMultiple
    @AppSettings(\.textEditing.wrapLinesToEditorWidth)
    var wrapLinesToEditorWidth
    @AppSettings(\.textEditing.font)
    var settingsFont
    @AppSettings(\.theme.useThemeBackground)
    var useThemeBackground
    @AppSettings(\.theme.matchAppearance)
    var matchAppearance
    @AppSettings(\.textEditing.letterSpacing)
    var letterSpacing
    @AppSettings(\.textEditing.bracketHighlight)
    var bracketHighlight

    @Environment(\.colorScheme)
    private var colorScheme

    @StateObject private var themeModel: ThemeModel = .shared

    private var cancellables = [AnyCancellable]()

    private let isEditable: Bool

    private let systemFont: NSFont = .monospacedSystemFont(ofSize: 11, weight: .medium)

    init(codeFile: CodeFileDocument, isEditable: Bool = true) {
        self.codeFile = codeFile
        self.isEditable = isEditable

        codeFile
            .$content
            .dropFirst()
            .debounce(
                for: 0.25,
                scheduler: DispatchQueue.main
            )
            .sink { _ in
                codeFile.autosave(withImplicitCancellability: false) { _ in
                }
            }
            .store(in: &cancellables)

        codeFile
            .$content
            .dropFirst()
            .sink { _ in
                codeFile.updateChangeCount(.changeDone)
            }
            .store(in: &cancellables)
    }

    @State private var selectedTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!

    @State private var font: NSFont = {
        return Settings[\.textEditing].font.current()
    }()

    @State private var bracketPairHighlight: BracketPairHighlight? = {
        let theme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!
        let color = Settings[\.textEditing].bracketHighlight.useCustomColor
        ? Settings[\.textEditing].bracketHighlight.color.nsColor
        : theme.editor.text.nsColor.withAlphaComponent(0.8)
        switch Settings[\.textEditing].bracketHighlight.highlightType {
        case .disabled:
            return nil
        case .flash:
            return .flash
        case .bordered:
            return .bordered(color: color)
        case .underline:
            return .underline(color: color)
        }
    }()

    @Environment(\.edgeInsets)
    private var edgeInsets

    @EnvironmentObject private var tabgroup: TabGroupData

    var body: some View {
        CodeEditTextView(
            $codeFile.content,
            language: getLanguage(),
            theme: selectedTheme.editor.editorTheme,
            font: font,
            tabWidth: codeFile.defaultTabWidth ?? defaultTabWidth,
            indentOption: (codeFile.indentOption ?? indentOption).textViewOption(),
            lineHeight: lineHeightMultiple,
            wrapLines: codeFile.wrapLines ?? wrapLinesToEditorWidth,
            cursorPosition: $codeFile.cursorPosition,
            useThemeBackground: useThemeBackground,
            contentInsets: edgeInsets.nsEdgeInsets,
            isEditable: isEditable,
            letterSpacing: letterSpacing,
            bracketPairHighlight: bracketPairHighlight
        )

        .id(codeFile.fileURL)
        .background {
            if colorScheme == .dark {
                EffectView(.underPageBackground)
            } else {
                EffectView(.contentBackground)
            }
        }
        .colorScheme(
            selectedTheme.appearance == .dark
            ? .dark
            : .light
        )
        // minHeight zero fixes a bug where the app would freeze if the contents of the file are empty.
        .frame(minHeight: .zero, maxHeight: .infinity)
        .onChange(of: themeModel.selectedTheme) { newValue in
            guard let theme = newValue else { return }
            self.selectedTheme = theme
        }
        .onChange(of: settingsFont) { newValue in
            font = NSFont(
                name: settingsFont.name,
                size: CGFloat(newValue.size)
            ) ?? systemFont.withSize(CGFloat(newValue.size))
        }
        .onChange(of: bracketHighlight) { _ in
            bracketPairHighlight = getBracketPairHighlight()
        }
    }

    private func getLanguage() -> CodeLanguage {
        guard let url = codeFile.fileURL else {
            return .default
        }
        return codeFile.language ?? CodeLanguage.detectLanguageFrom(
            url: url,
            prefixBuffer: codeFile.content.getFirstLines(5),
            suffixBuffer: codeFile.content.getLastLines(5)
        )
    }

    private func getBracketPairHighlight() -> BracketPairHighlight? {
        let theme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!
        let color = Settings[\.textEditing].bracketHighlight.useCustomColor
        ? Settings[\.textEditing].bracketHighlight.color.nsColor
        : theme.editor.text.nsColor.withAlphaComponent(0.8)
        switch Settings[\.textEditing].bracketHighlight.highlightType {
        case .disabled:
            return nil
        case .flash:
            return .flash
        case .bordered:
            return .bordered(color: color)
        case .underline:
            return .underline(color: color)
        }
    }
}

// This extension is kept here because it should not be used elsewhere in the app and may cause confusion
// due to the similar type name from the CETV module.
private extension SettingsData.TextEditingSettings.IndentOption {
    func textViewOption() -> IndentOption {
        switch self.indentType {
        case .spaces:
            return IndentOption.spaces(count: spaceCount)
        case .tab:
            return IndentOption.tab
        }
    }
}
