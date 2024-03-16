//
//  CodeFileView.swift
//  CodeEditModules/CodeFile
//
//  Created by Marco Carnevali on 17/03/22.
//

import Foundation
import SwiftUI
import CodeEditSourceEditor
import CodeEditTextView
import CodeEditLanguages
import Combine

/// CodeFileView is just a wrapper of the `CodeEditor` dependency
struct CodeFileView: View {
    @ObservedObject private var codeFile: CodeFileDocument

    /// The current cursor positions in the view
    @State private var cursorPositions: [CursorPosition] = []

    /// Any coordinators passed to the view.
    private var textViewCoordinators: [TextViewCoordinator]

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

    @EnvironmentObject private var editorManager: EditorManager

    @StateObject private var themeModel: ThemeModel = .shared

    private var cancellables = [AnyCancellable]()

    private let isEditable: Bool

    private let undoManager = CEUndoManager()

    init(codeFile: CodeFileDocument, textViewCoordinators: [TextViewCoordinator] = [], isEditable: Bool = true) {
        self.codeFile = codeFile
        self.textViewCoordinators = textViewCoordinators
        self.isEditable = isEditable

        if let openOptions = codeFile.openOptions {
            codeFile.openOptions = nil
            self.cursorPositions = openOptions.cursorPositions
        }

        codeFile
            .$content
            .dropFirst()
            .debounce(
                for: 0.25,
                scheduler: DispatchQueue.main
            )
            .sink { _ in
                codeFile.updateChangeCount(.changeDone)
                codeFile.autosave(withImplicitCancellability: false) { _ in
                }
            }
            .store(in: &cancellables)

        codeFile.undoManager = self.undoManager.manager
    }

    @State private var selectedTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!

    @State private var font: NSFont = Settings[\.textEditing].font.current

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

    @EnvironmentObject private var editor: Editor

    var body: some View {
        CodeEditSourceEditor(
            $codeFile.content,
            language: getLanguage(),
            theme: selectedTheme.editor.editorTheme,
            font: font,
            tabWidth: codeFile.defaultTabWidth ?? defaultTabWidth,
            indentOption: (codeFile.indentOption ?? indentOption).textViewOption(),
            lineHeight: lineHeightMultiple,
            wrapLines: codeFile.wrapLines ?? wrapLinesToEditorWidth,
            cursorPositions: $cursorPositions,
            useThemeBackground: useThemeBackground,
            contentInsets: edgeInsets.nsEdgeInsets,
            isEditable: isEditable,
            letterSpacing: letterSpacing,
            bracketPairHighlight: bracketPairHighlight,
            undoManager: undoManager,
            coordinators: textViewCoordinators
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
        .onChange(of: settingsFont) { newFontSetting in
            font = newFontSetting.current
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
