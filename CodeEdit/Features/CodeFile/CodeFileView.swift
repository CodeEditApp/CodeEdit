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
    private var prefs: AppPreferencesModel = .shared

    @Environment(\.colorScheme)
    private var colorScheme

    private var cancellables = [AnyCancellable]()

    private let editable: Bool

    init(codeFile: CodeFileDocument, editable: Bool = true) {
        self.codeFile = codeFile
        self.editable = editable

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
        return AppPreferencesModel.shared.preferences.textEditing.font.current()
    }()

    var body: some View {
        CodeEditTextView(
            $codeFile.content,
            language: getLanguage(),
            theme: $selectedTheme.editor.editorTheme,
            font: $font,
            tabWidth: $prefs.preferences.textEditing.defaultTabWidth,
            lineHeight: $prefs.preferences.textEditing.lineHeightMultiple,
            wrapLines: $prefs.preferences.textEditing.wrapLinesToEditorWidth,
            cursorPosition: codeFile.$cursorPosition,
            useThemeBackground: prefs.preferences.theme.useThemeBackground
        )
        .id(codeFile.fileURL)
        .background {
            if colorScheme == .dark {
                if prefs.preferences.theme.selectedTheme == prefs.preferences.theme.selectedLightTheme {
                    Color.white
                } else {
                    EffectView(.underPageBackground)
                }
            } else {
                if prefs.preferences.theme.selectedTheme == prefs.preferences.theme.selectedDarkTheme {
                    Color.black
                } else {
                    EffectView(.contentBackground)
                }

            }
        }
        .disabled(!editable)
        .frame(maxHeight: .infinity)
        .onChange(of: ThemeModel.shared.selectedTheme) { newValue in
            guard let theme = newValue else { return }
            self.selectedTheme = theme
        }
        .onChange(of: colorScheme) { newValue in
            if prefs.preferences.theme.mirrorSystemAppearance {
                ThemeModel.shared.selectedTheme = newValue == .dark
                    ? ThemeModel.shared.selectedDarkTheme!
                    : ThemeModel.shared.selectedLightTheme!
            }
        }
        .onChange(of: prefs.preferences.textEditing.font) { _ in
            font = AppPreferencesModel.shared.preferences.textEditing.font.current()
        }
    }

    private func getLanguage() -> CodeLanguage {
        guard let url = codeFile.fileURL else {
            return .default
        }
        return .detectLanguageFrom(url: url)
    }
}
