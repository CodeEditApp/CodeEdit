//
//  CodeFileView.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 17/03/22.
//

import Highlightr
import Foundation
import SwiftUI

/// CodeFileView is just a wrapper of the `CodeEditor` dependency
public struct CodeFileView: View {
    @ObservedObject
    private var codeFile: CodeFileDocument

    @AppStorage(Theme.storageKey)
    var theme: Theme = .atelierSavannaAuto

    @Environment(\.colorScheme)
    private var colorScheme

    private let editable: Bool

    public init(codeFile: CodeFileDocument, editable: Bool = true) {
        self.codeFile = codeFile
        self.editable = editable
    }

    public var body: some View {
        CodeEditor(
            content: $codeFile.content,
            language: getLanguage(),
            theme: $theme
        )
        .disabled(!editable)
    }

    private func getLanguage() -> CodeLanguage? {
        if let url = codeFile.fileURL {
            return .detectLanguageFromUrl(url: url)
        } else {
            return .default
        }
    }

    private func getTheme() -> Theme {
        if theme == .atelierSavannaAuto {
            return colorScheme == .light ? .atelierSavannaLight : .atelierSavannaDark
        }
        return theme
    }
}
