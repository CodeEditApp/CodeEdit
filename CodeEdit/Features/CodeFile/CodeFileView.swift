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
    @ObservedObject
    private var codeFile: CodeFileDocument

    @ObservedObject
    private var prefs: SettingsModel = .shared

    @Environment(\.colorScheme)
    private var colorScheme

    private var cancellables = [AnyCancellable]()

    private let isEditable: Bool

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

    @State
    private var selectedTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!

    @State
    private var font: NSFont = {
        return SettingsModel.shared.settings.textEditing.font.current()
    }()

    @Environment(\.edgeInsets)
    private var edgeInsets

    @EnvironmentObject
    private var tabgroup: TabGroupData

    var body: some View {
        CodeEditTextView(
            $codeFile.content,
            language: getLanguage(),
            theme: $selectedTheme.editor.editorTheme,
            font: $font,
            tabWidth: $prefs.settings.textEditing.defaultTabWidth,
            lineHeight: $prefs.settings.textEditing.lineHeightMultiple,
            wrapLines: $prefs.settings.textEditing.wrapLinesToEditorWidth,
            cursorPosition: $codeFile.cursorPosition,
            useThemeBackground: prefs.settings.theme.useThemeBackground,
            contentInsets: edgeInsets.nsEdgeInsets,
            isEditable: isEditable
        )
        .id(codeFile.fileURL)
        .background {
            if colorScheme == .dark {
                if prefs.settings.theme.selectedTheme == prefs.settings.theme.selectedLightTheme {
                    Color.white
                } else {
                    EffectView(.underPageBackground)
                }
            } else {
                if prefs.settings.theme.selectedTheme == prefs.settings.theme.selectedDarkTheme {
                    Color.black
                } else {
                    EffectView(.contentBackground)
                }

            }
        }
        // minHeight zero fixes a bug where the app would freeze if the contents of the file are empty.
        .frame(minHeight: .zero, maxHeight: .infinity)
        .onChange(of: ThemeModel.shared.selectedTheme) { newValue in
            guard let theme = newValue else { return }
            self.selectedTheme = theme
        }
        .onChange(of: colorScheme) { newValue in
            if prefs.settings.theme.mirrorSystemAppearance {
                ThemeModel.shared.selectedTheme = newValue == .dark
                    ? ThemeModel.shared.selectedDarkTheme!
                    : ThemeModel.shared.selectedLightTheme!
            }
        }
        .onChange(of: prefs.settings.textEditing.font) { _ in
            font = SettingsModel.shared.settings.textEditing.font.current()
        }
    }

    private func getLanguage() -> CodeLanguage {
        guard let url = codeFile.fileURL else {
            return .default
        }
        return .detectLanguageFrom(url: url)
    }
}
