//
//  OutlineTableViewCell.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI

protocol OutlineTableViewCellDelegate: AnyObject {
    func moveFile(file: CEWorkspaceFile, to destination: URL)
    func copyFile(file: CEWorkspaceFile, to destination: URL)
    func cellDidFinishEditing()
}

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class ProjectNavigatorTableViewCell: FileSystemTableViewCell {
    private weak var delegate: OutlineTableViewCellDelegate?

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - item: The file item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    ///   - navigatorFilter: An optional string use to filter the navigator area.
    ///                      (Used for bolding and changing primary/secondary color).
    init(
        frame frameRect: NSRect,
        item: CEWorkspaceFile?,
        isEditable: Bool = true,
        delegate: OutlineTableViewCellDelegate? = nil,
        navigatorFilter: String? = nil
    ) {
        super.init(frame: frameRect, item: item, isEditable: isEditable, navigatorFilter: navigatorFilter)
        self.textField?.setAccessibilityIdentifier("ProjectNavigatorTableViewCell-\(item?.name ?? "")")
        self.delegate = delegate
    }

    /// *Not Implemented*
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        fatalError("""
        init(frame: ) isn't implemented on `OutlineTableViewCell`.
        Please use `.init(frame: NSRect, item: WorkspaceClient.FileItem?)
        """)
    }

    /// *Not Implemented*
    required init?(coder: NSCoder) {
        fatalError("""
        init?(coder: NSCoder) isn't implemented on `OutlineTableViewCell`.
        Please use `.init(frame: NSRect, item: WorkspaceClient.FileItem?)
        """)
    }

    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let fileItem else { return }

        if fileItem.phantomFile != nil {
            DispatchQueue.main.async { [weak fileItem, weak self] in
                guard let fileItem, let self = self else { return }
                self.handlePhantomFileCompletion(fileItem: fileItem, wasCancelled: false)
            }
        } else {
            textField?.backgroundColor = fileItem.validateFileName(for: textField?.stringValue ?? "") ? .none : errorRed
            if fileItem.validateFileName(for: textField?.stringValue ?? "") {
                let destinationURL = fileItem.url
                    .deletingLastPathComponent()
                    .appending(path: textField?.stringValue ?? "")
                delegate?.moveFile(file: fileItem, to: destinationURL)
            } else {
                textField?.stringValue = fileItem.labelFileName()
            }
        }
        delegate?.cellDidFinishEditing()
    }

    private func handlePhantomFileCompletion(fileItem: CEWorkspaceFile, wasCancelled: Bool) {
        if wasCancelled {
            if let workspace = delegate as? ProjectNavigatorViewController,
               let workspaceFileManager = workspace.workspace?.workspaceFileManager {
                removePhantomFile(fileItem: fileItem, fileManager: workspaceFileManager)
            }
            return
        }

        let newName = textField?.stringValue ?? ""
        if !newName.isEmpty && newName.isValidFilename {
            if let workspace = delegate as? ProjectNavigatorViewController,
               let workspaceFileManager = workspace.workspace?.workspaceFileManager,
               let parent = fileItem.parent {
                do {
                    if fileItem.isFolder {
                        let newFolder = try workspaceFileManager.addFolder(
                            folderName: newName,
                            toFile: parent
                        )
                        workspace.workspace?.listenerModel.highlightedFileItem = newFolder
                    } else {
                        let newFile = try workspaceFileManager.addFile(
                            fileName: newName,
                            toFile: parent,
                            contents: fileItem.phantomFile == PhantomFile.pasteboardContent
                            ? NSPasteboard.general.string(forType: .string)?.data(using: .utf8)
                            : nil
                        )
                        workspace.workspace?.listenerModel.highlightedFileItem = newFile
                        workspace.workspace?.editorManager?.openTab(item: newFile)
                    }
                } catch {
                    let alert = NSAlert(error: error)
                    alert.addButton(withTitle: "Dismiss")
                    alert.runModal()
                }

                removePhantomFile(fileItem: fileItem, fileManager: workspaceFileManager)
            }
        } else {
            if let workspace = delegate as? ProjectNavigatorViewController,
               let workspaceFileManager = workspace.workspace?.workspaceFileManager {
                removePhantomFile(fileItem: fileItem, fileManager: workspaceFileManager)
            }
        }
    }

    private func removePhantomFile(fileItem: CEWorkspaceFile, fileManager: CEWorkspaceFileManager) {
        fileManager.flattenedFileItems.removeValue(forKey: fileItem.id)

        if let parent = fileItem.parent,
           let childrenIds = fileManager.childrenMap[parent.id] {
            fileManager.childrenMap[parent.id] = childrenIds.filter { $0 != fileItem.id }
        }

        if let workspace = delegate as? ProjectNavigatorViewController {
            workspace.outlineView.reloadData()
        }
    }

    /// Capture a cancel operation (escape key) to remove a phantom file that we are currently renaming
    func control(
        _ control: NSControl,
        textView: NSTextView,
        doCommandBy commandSelector: Selector
    ) -> Bool {
        guard let fileItem, fileItem.phantomFile != nil else { return false }

        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            DispatchQueue.main.async { [weak fileItem, weak self] in
                guard let fileItem, let self = self else { return }
                self.handlePhantomFileCompletion(fileItem: fileItem, wasCancelled: true)
            }
        }

        return false
    }
}
