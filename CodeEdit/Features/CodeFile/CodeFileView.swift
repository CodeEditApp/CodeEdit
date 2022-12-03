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
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    var body: some View {
        CodeEditTextView(
            $codeFile.content,
            language: getLanguage(),
            theme: $selectedTheme.editor.editorTheme,
            font: $font,
            tabWidth: $prefs.preferences.textEditing.defaultTabWidth,
            lineHeight: .constant(1.2), // TODO: Add to preferences
            cursorPosition: codeFile.$cursorPosition
        )
        .id(codeFile.fileURL)
        .background(selectedTheme.editor.background.swiftColor)
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
            font = NSFont(
                name: prefs.preferences.textEditing.font.name,
                size: Double(prefs.preferences.textEditing.font.size)
            ) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)
        }
    }

    private func getLanguage() -> CodeLanguage {
        guard let url = codeFile.fileURL else {
            return .default
        }
        return .detectLanguageFrom(url: url)
    }
}
