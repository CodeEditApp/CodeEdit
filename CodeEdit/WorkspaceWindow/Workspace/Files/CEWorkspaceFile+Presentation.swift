//
//  CEWorkspaceFile+Presentation.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import SwiftUI
import CodeEditCore
import CodeEditSettings
import CodeEditUI

extension CEWorkspaceFile {
    // MARK: Icons

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
    ///
    /// Matches on the file's real extension. It used to compare `type.rawValue`, which
    /// silently failed twice over: the raw value for `.txt` was `"text"`, so a user
    /// entering `txt` never matched, and any extension absent from the `FileType` enum
    /// fell back to `.txt` and so reported itself as `"text"`.
    func labelFileName() -> String {
        let prefs = Settings.shared.preferences.general
        switch prefs.fileExtensionsVisibility {
        case .hideAll:
            return self.fileName(typeHidden: true)
        case .showAll:
            return self.fileName(typeHidden: false)
        case .showOnly:
            return self.fileName(typeHidden: !prefs.shownFileExtensions.extensions.contains(url.pathExtension))
        case .hideOnly:
            return self.fileName(typeHidden: prefs.hiddenFileExtensions.extensions.contains(url.pathExtension))
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
