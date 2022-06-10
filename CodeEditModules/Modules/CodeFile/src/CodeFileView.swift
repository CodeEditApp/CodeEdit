//
//  CodeFileView.swift
//  CodeEditModules/CodeFile
//
//  Created by Marco Carnevali on 17/03/22.
//

import Highlightr
import Foundation
import SwiftUI
import CodeEditTextView
import AppPreferences

/// CodeFileView is just a wrapper of the `CodeEditor` dependency
public struct CodeFileView: View {
    @ObservedObject
    private var codeFile: CodeFileDocument

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @Environment(\.colorScheme)
    private var colorScheme

    private let editable: Bool

    public init(codeFile: CodeFileDocument, editable: Bool = true) {
        self.codeFile = codeFile
        self.editable = editable
    }

    @State
    private var selectedTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!

    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    public var body: some View {
        CodeEditTextView(
            $codeFile.content,
            language: getLanguage(),
            theme: $selectedTheme.editor.editorTheme,
            font: $font,
            tabWidth: $prefs.preferences.textEditing.defaultTabWidth,
            lineHeight: .constant(1.2) // TODO: Add to preferences
        )
        .id(codeFile.fileURL)
        .background(selectedTheme.editor.background.swiftColor)
        .disabled(!editable)
        .frame(maxHeight: .infinity)
        .onChange(of: ThemeModel.shared.selectedTheme) { newValue in
            guard let theme = newValue else { return }
            self.selectedTheme = theme
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
