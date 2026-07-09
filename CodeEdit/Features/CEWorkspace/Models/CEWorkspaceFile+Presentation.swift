//
//  CEWorkspaceFile+Presentation.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import SwiftUI
import CodeEditSettings
import CodeEditCore

extension CEWorkspaceFile {
    /// The file's icon as a SwiftUI `Image`.
    var icon: Image {
        if let customImage = NSImage.symbol(named: systemImage) {
            return Image(nsImage: customImage)
        } else {
            return Image(systemName: systemImage)
        }
    }

    /// The file's icon as an `NSImage`.
    var nsIcon: NSImage {
        if let customImage = NSImage.symbol(named: systemImage) {
            return customImage
        } else {
            return NSImage(systemSymbolName: systemImage, accessibilityDescription: systemImage)
                ?? NSImage(systemSymbolName: "doc", accessibilityDescription: "doc")!
        }
    }

    /// SF Symbol name for the file/folder.
    var systemImage: String {
        if isFolder {
            return folderIcon()
        } else {
            return FileIcon.fileIcon(fileType: type)
        }
    }

    /// Icon tint color for the file type.
    var iconColor: Color {
        FileIcon.iconColor(fileType: type)
    }

    /// SF Symbol name for folders (root / `.codeedit` / populated / empty).
    private func folderIcon() -> String {
        if self.parent == nil { return "folder.fill.badge.gearshape" }
        if self.name == ".codeedit" { return "folder.fill.badge.gearshape" }
        return isEmptyFolder ? "folder" : "folder.fill"
    }

    // MARK: Intents

    /// Reveal the file/folder in Finder.
    func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    /// Open the file/folder with the system default application.
    func openWithExternalEditor() {
        NSWorkspace.shared.open(url)
    }

    // MARK: Display name (user preference driven)

    /// A display name honoring the user's file-extension-visibility preference.
    func labelFileName() -> String {
        let prefs = Settings.shared.preferences.general
        switch prefs.fileExtensionsVisibility {
        case .hideAll:
            return self.fileName(typeHidden: true)
        case .showAll:
            return self.fileName(typeHidden: false)
        case .showOnly:
            return self.fileName(typeHidden: !prefs.shownFileExtensions.extensions.contains(self.type.rawValue))
        case .hideOnly:
            return self.fileName(typeHidden: prefs.hiddenFileExtensions.extensions.contains(self.type.rawValue))
        }
    }

    func validateFileName(for newName: String) -> Bool {
        guard newName != labelFileName() &&
                !newName.isEmpty &&
                newName.isValidFilename &&
                !FileManager.default.fileExists(
                    atPath: self.url.deletingLastPathComponent().appending(path: newName).path
                ) else {
            return false
        }
        return true
    }
}
