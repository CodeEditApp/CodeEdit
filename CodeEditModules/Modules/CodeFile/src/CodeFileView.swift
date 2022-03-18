//
//  CodeFileView.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 17/03/22.
//

import CodeEditor
import Foundation
import SwiftUI

/// CodeFileView is just a wrapper of the `CodeEditor` dependency
public struct CodeFileView: View {
    @ObservedObject public var codeFile: CodeFileDocument
    @Environment(\.colorScheme) private var colorScheme

    public init(codeFile: CodeFileDocument) {
        self.codeFile = codeFile
    }

    public var body: some View {
        CodeEditor(
            source: $codeFile.content,
            language: codeFile.fileLanguage(),
            theme: colorScheme == .light ? .atelierSavannaLight : .atelierSavannaDark,
            indentStyle: .system
        )
    }
}
