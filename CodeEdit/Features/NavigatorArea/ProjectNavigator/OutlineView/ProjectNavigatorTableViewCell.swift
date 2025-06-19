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
        textField?.backgroundColor = fileItem.validateFileName(for: textField?.stringValue ?? "") ? .none : errorRed
        if fileItem.validateFileName(for: textField?.stringValue ?? "") {
            let destinationURL = fileItem.url
                .deletingLastPathComponent()
                .appending(path: textField?.stringValue ?? "")
            delegate?.moveFile(file: fileItem, to: destinationURL)
        } else {
            textField?.stringValue = fileItem.labelFileName()
        }
        delegate?.cellDidFinishEditing()
    }
}
