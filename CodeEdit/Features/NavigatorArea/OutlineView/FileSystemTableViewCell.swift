//
//  FileSystemOutlineView.swift
//  CodeEdit
//
//  Created by TAY KAI QUAN on 14/8/22.
//

import SwiftUI

class FileSystemTableViewCell: StandardTableViewCell {

    var fileItem: CEWorkspaceFile!

    var changeLabelLargeWidth: NSLayoutConstraint!
    var changeLabelSmallWidth: NSLayoutConstraint!

    private let prefs = Settings.shared.preferences.general

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - item: The file item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    init(frame frameRect: NSRect, item: CEWorkspaceFile?, isEditable: Bool = true) {
        super.init(frame: frameRect, isEditable: isEditable)

        if let item = item {
            addIcon(item: item)
        }
        addModel()
    }

    override func configLabel(label: NSTextField, isEditable: Bool) {
        super.configLabel(label: label, isEditable: isEditable)
        label.delegate = self
    }

    func addIcon(item: CEWorkspaceFile) {
        fileItem = item
        icon.image = item.nsIcon
        icon.contentTintColor = color(for: item)
        toolTip = item.labelFileName()
        label.stringValue = item.labelFileName()
    }

    func addModel() {
        secondaryLabel.stringValue = fileItem.gitStatus?.description ?? ""
        if secondaryLabel.stringValue == "?" { secondaryLabel.stringValue = "A" }
    }

    /// *Not Implemented*
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        fatalError("""
            init(frame: ) isn't implemented on `OutlineTableViewCell`.
            Please use `.init(frame: NSRect, item: FileSystemClient.FileItem?)
            """)
    }

    /// *Not Implemented*
    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `OutlineTableViewCell`.
            Please use `.init(frame: NSRect, item: FileSystemClient.FileItem?)
            """)
    }

    /// Returns the font size for the current row height. Defaults to `13.0`
    private var fontSize: Double {
        switch self.frame.height {
        case 20: return 11
        case 22: return 13
        case 24: return 14
        default: return 13
        }
    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// - Parameter item: The `FileItem` to get the color for
    /// - Returns: A `NSColor` for the given `FileItem`.
    func color(for item: CEWorkspaceFile) -> NSColor {
        if !item.isFolder && prefs.fileIconStyle == .color {
            return NSColor(item.iconColor)
        } else {
            return NSColor(named: "FolderBlue")!
        }
    }
}

let errorRed = NSColor(red: 1, green: 0, blue: 0, alpha: 0.2)
extension FileSystemTableViewCell: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        label.backgroundColor = fileItem.validateFileName(for: label?.stringValue ?? "") ? .none : errorRed
    }
    func controlTextDidEndEditing(_ obj: Notification) {
        label.backgroundColor = fileItem.validateFileName(for: label?.stringValue ?? "") ? .none : errorRed
        if fileItem.validateFileName(for: label?.stringValue ?? "") {
            let newURL = fileItem.url.deletingLastPathComponent().appendingPathComponent(label?.stringValue ?? "")
            workspace?.workspaceFileManager?.move(file: fileItem, to: newURL)
        } else {
            label?.stringValue = fileItem.labelFileName()
        }
    }
}

extension String {
    var isValidFilename: Bool {
        let regex = "[^:]"
        let testString = NSPredicate(format: "SELF MATCHES %@", regex)
        return !testString.evaluate(with: self)
    }
}
