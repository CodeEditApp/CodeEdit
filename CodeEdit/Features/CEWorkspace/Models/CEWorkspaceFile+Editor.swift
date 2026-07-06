//
//  CEWorkspaceFile+Editor.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import CodeEditCore

extension CEWorkspaceFile: EditorTabRepresentable {
    /// The `id` in `EditorTabID` form.
    var tabID: EditorTabID { .codeEditor(id) }
}
