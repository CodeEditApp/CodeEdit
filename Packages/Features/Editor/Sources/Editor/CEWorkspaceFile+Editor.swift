//
//  CEWorkspaceFile+Editor.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import SwiftUI
import CodeEditCore
import CodeEditSymbols

extension CEWorkspaceFile: EditorTabRepresentable {
    public var tabID: EditorTabID { .codeEditor(id) }

    var icon: Image {
        if let customImage = NSImage.symbol(named: systemImage) {
            return Image(nsImage: customImage)
        } else {
            return Image(systemName: systemImage)
        }
    }

    var nsIcon: NSImage {
        if let customImage = NSImage.symbol(named: systemImage) {
            return customImage
        } else {
            return NSImage(systemSymbolName: systemImage, accessibilityDescription: systemImage)
                ?? NSImage(systemSymbolName: "doc", accessibilityDescription: "doc")!
        }
    }

    var iconColor: Color {
        FileIcon.iconColor(fileType: type)
    }

    var systemImage: String {
        if isFolder {
            if self.parent == nil { return "folder.fill.badge.gearshape" }
            if self.name == ".codeedit" { return "folder.fill.badge.gearshape" }
            return isEmptyFolder ? "folder" : "folder.fill"
        } else {
            return FileIcon.fileIcon(fileType: type)
        }
    }
}
