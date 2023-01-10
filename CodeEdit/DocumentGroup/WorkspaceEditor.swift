//
//  WorkspaceEditor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 04/01/2023.
//

import SwiftUI
import CodeEditTextView

indirect enum WorkspaceLayout: View {

    case one(Int)

    case horizontal(Int, WorkspaceLayout)

    case vertical(Int, WorkspaceLayout)

    var body: some View {
        switch self {
        case .one(let file):
            ReferenceWorkspaceEditor(identifier: file)
        case .horizontal(let file, let workspaceLayout):
            HSplitView {
                ReferenceWorkspaceEditor(identifier: file)
                workspaceLayout
            }
        case .vertical(let file, let workspaceLayout):
            VSplitView {
                ReferenceWorkspaceEditor(identifier: file)
                workspaceLayout
            }
        }
    }

    var file: Int {
        switch self {
        case .one(let url):
            return url
        case .horizontal(let url, _), .vertical(let url, _):
            return url
        }
    }
}



//swiftlint:disable all



struct ReferenceWorkspaceEditor: View {
    @EnvironmentObject var doc: ReferenceWorkspaceFileDocument
    var identifier: Int
    var body: some View {
        VStack {
            HStack {
                Text("Tabbar")
            }
            TextEditor(text: $doc.currentFile)
//            CodeEditTextView(
//                $doc.currentFile,
//                language: .swift,
//                theme: .constant(ThemeModel.shared.selectedTheme!.editor.editorTheme),
//                font: .constant(.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)),
//                tabWidth: .constant(4),
//                lineHeight: .constant(1.4))
//            

//            .id(doc.currentWrapper?.filename)
        }
    }
}
