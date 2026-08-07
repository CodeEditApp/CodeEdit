//
//  CEWorkspaceFile+Editor.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import SwiftUI
import CodeEditCore
import CodeEditUI

extension CEWorkspaceFile: EditorTabRepresentable {
    public var tabID: EditorTabID { .codeEditor(id) }

    /// Symbol + tint for this file or folder, from ``CodeEditUI/FileIcon``.
    var iconSpec: FileIconSpec {
        isFolder
            ? FileIcon.folderSpec(
                isEmpty: isEmptyFolder,
                isRoot: parent == nil,
                isCodeEditDirectory: name == ".codeedit"
              )
            : FileIcon.spec(for: url)
    }

    var icon: Image { iconSpec.image }
    var nsIcon: NSImage { iconSpec.nsImage }
    var iconColor: Color { iconSpec.color }
}
