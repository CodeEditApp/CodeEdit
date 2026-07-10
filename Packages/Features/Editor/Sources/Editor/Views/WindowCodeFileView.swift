//
//  WindowCodeFileView.swift
//  CodeEdit
//
//  Created by Khan Winter on 3/19/23.
//

import Foundation
import CodeEditDocument
import CodeEditCore
import SwiftUI

/// View that fixes [#1158](https://github.com/CodeEditApp/CodeEdit/issues/1158)
/// # Should **not** be used other than in a single file window.
public struct WindowCodeFileView: View {
    @StateObject var editorInstance: EditorInstance
    @StateObject var undoRegistration: UndoManagerRegistration = UndoManagerRegistration()
    var codeFile: CodeFileDocument

    public init(codeFile: CodeFileDocument) {
        self._editorInstance = .init(
            wrappedValue: EditorInstance(
                findReplaceQuery: nil,
                file: CEWorkspaceFile(url: codeFile.fileURL ?? URL(fileURLWithPath: ""))
            )
        )
        self.codeFile = codeFile
    }

    public var body: some View {
        if let utType = codeFile.utType, utType.conforms(to: .text) {
            CodeFileView(editorInstance: editorInstance, codeFile: codeFile)
                .environmentObject(undoRegistration)
        } else {
            NonTextFileView(fileDocument: codeFile)
        }
    }
}
