//
//  ThemedCodeView.swift
//  
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import CodeEditor

public struct ThemedCodeView: View {
    @Binding public var content: String
    public var language: CodeEditor.Language
    public var editable: Bool
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(CodeEditorTheme.storageKey) var theme: CodeEditor.ThemeName = .atelierSavannaAuto

    public init(_ content: Binding<String>, language: CodeEditor.Language, editable: Bool = true) {
        self._content = content
        self.language = language
        self.editable = editable
    }

    public var body: some View {
        CodeEditor(
            source: $content,
            language: language,
            theme: getTheme(),
            flags: editable ? .defaultEditorFlags : .defaultViewerFlags,
            indentStyle: .system
        )
    }

    private func getTheme() -> CodeEditor.ThemeName {
        if theme == .atelierSavannaAuto {
            return colorScheme == .light ? .atelierSavannaLight : .atelierSavannaDark
        }
        return theme
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ThemedCodeView(.constant("## Example"), language: .markdown)
    }
}
