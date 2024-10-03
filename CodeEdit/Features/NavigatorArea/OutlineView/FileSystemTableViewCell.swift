//
//  FileSystemOutlineView.swift
//  CodeEdit
//
//  Created by TAY KAI QUAN on 14/8/22.
//

import SwiftUI

class FileSystemTableViewCell: StandardTableViewCell {

    weak var fileItem: CEWorkspaceFile?

    var changeLabelLargeWidth: NSLayoutConstraint!
    var changeLabelSmallWidth: NSLayoutConstraint!

    private let prefs = Settings.shared.preferences.general

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - item: The file item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    init(frame frameRect: NSRect, item: CEWorkspaceFile?, isEditable: Bool = true, workspace: WorkspaceDocument?) {
        super.init(frame: frameRect, isEditable: isEditable, workspace: workspace)

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
        imageView?.image = item.nsIcon
        imageView?.contentTintColor = color(for: item)

        let fileName = item.labelFileName()
        textField?.stringValue = fileName

        // Apply bold style if the filename matches the workspace filter
        if let filter = workspace?.filter, fileName.localizedLowercase.contains(filter.localizedLowercase) {
            let attributedString = NSMutableAttributedString(string: fileName)
            let range = NSString(string: fileName).range(of: filter, options: .caseInsensitive)
            attributedString.addAttribute(
                .font,
                value: NSFont.boldSystemFont(ofSize: textField?.font?.pointSize ?? 12),
                range: range
            )
            textField?.attributedStringValue = attributedString
        } else {
            // Reset to normal font if no match
            textField?.attributedStringValue = NSAttributedString(string: fileName)
        }
    }

    func addModel() {
        guard let fileItem = fileItem, let secondaryLabel = secondaryLabel else {
            return
        }

        if fileItem.url.isSymbolicLink { secondaryLabel.stringValue = "􀰞" }

        guard let gitStatus = fileItem.gitStatus?.description else {
            return
        }

        if gitStatus == "?" { secondaryLabel.stringValue += "A" } else {
            secondaryLabel.stringValue += gitStatus
        }
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
        if prefs.fileIconStyle == .color {
            if !item.isFolder {
                return NSColor(item.iconColor)
            } else {
                return NSColor(named: "FolderBlue") ?? NSColor(.cyan)
            }
        } else {
            return NSColor(named: "CoolGray") ?? NSColor(.gray)
        }
    }

    deinit {
        toolTip = nil
    }
}

let errorRed = NSColor(red: 1, green: 0, blue: 0, alpha: 0.2)
extension FileSystemTableViewCell: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let fileItem else { return }
        textField?.backgroundColor = fileItem.validateFileName(for: textField?.stringValue ?? "") ? .none : errorRed
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        guard let fileItem else { return }
        textField?.backgroundColor = fileItem.validateFileName(for: textField?.stringValue ?? "") ? .none : errorRed
        if fileItem.validateFileName(for: textField?.stringValue ?? "") {
            let newURL = fileItem.url.deletingLastPathComponent().appendingPathComponent(textField?.stringValue ?? "")
            workspace?.workspaceFileManager?.move(file: fileItem, to: newURL)
        } else {
            textField?.stringValue = fileItem.labelFileName()
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
