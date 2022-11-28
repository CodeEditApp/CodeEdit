//
//  OutlineTableViewCell.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI

protocol OutlineTableViewCellDelegate: AnyObject {
    func moveFile(file: WorkspaceClient.FileItem, to destination: URL)
}

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class OutlineTableViewCell: NSTableCellView {

    var label: NSTextField!
    var icon: NSImageView!
    private var fileItem: WorkspaceClient.FileItem!
    private var delegate: OutlineTableViewCellDelegate?

    private let prefs = AppPreferencesModel.shared.preferences.general

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - item: The file item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    init(frame frameRect: NSRect, item: WorkspaceClient.FileItem?,
         isEditable: Bool = true,
         delegate: OutlineTableViewCellDelegate? = nil) {
        super.init(frame: frameRect)

        self.delegate = delegate

        // Create the label

        self.label = NSTextField(frame: .zero)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.drawsBackground = false
        self.label.isBordered = false
        self.label.isEditable = isEditable
        self.label.isSelectable = isEditable
        self.label.delegate = self
        self.label.layer?.cornerRadius = 10.0
        self.label.font = .labelFont(ofSize: fontSize)
        self.label.lineBreakMode = .byTruncatingMiddle

        self.addSubview(label)
        self.textField = label

        // Create the icon

        self.icon = NSImageView(frame: .zero)
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.icon.symbolConfiguration = .init(pointSize: fontSize, weight: .regular, scale: .medium)

        self.addSubview(icon)
        self.imageView = icon

        // Icon constraints

        self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -2).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: frameRect.height).isActive = true

        // Label constraints

        self.label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 1).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 1).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        if let item = item {
            let image = NSImage(systemSymbolName: item.systemImage, accessibilityDescription: nil)!
            fileItem = item
            icon.image = image
            icon.contentTintColor = color(for: item)

            label.stringValue = label(for: item)
        }
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

    /// Returns the font size for the current row height. Defaults to `13.0`
    private var fontSize: Double {
        switch self.frame.height {
        case 20: return 11
        case 22: return 13
        case 24: return 14
        default: return 13
        }
    }

    /// Generates a string based on user's file name preferences.
    /// - Parameter item: The FileItem to generate the name for.
    /// - Returns: A `String` with the name to display.
    private func label(for item: WorkspaceClient.FileItem) -> String {
        switch prefs.fileExtensionsVisibility {
        case .hideAll:
            return item.fileName(typeHidden: true)
        case .showAll:
            return item.fileName(typeHidden: false)
        case .showOnly:
            return item.fileName(typeHidden: !prefs.shownFileExtensions.extensions.contains(item.fileType.rawValue))
        case .hideOnly:
            return item.fileName(typeHidden: prefs.hiddenFileExtensions.extensions.contains(item.fileType.rawValue))
        }
    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// - Parameter item: The `FileItem` to get the color for
    /// - Returns: A `NSColor` for the given `FileItem`.
    private func color(for item: WorkspaceClient.FileItem) -> NSColor {
        if item.children == nil && prefs.fileIconStyle == .color {
            return NSColor(item.iconColor)
        } else {
            return NSColor(named: "FolderBlue")!
        }
    }
}

let errorRed = NSColor.init(red: 1, green: 0, blue: 0, alpha: 0.2)
extension OutlineTableViewCell: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        print("Contents changed to \(label?.stringValue ?? "idk")")
        print("File validity: \(validateFileName(for: label?.stringValue ?? ""))")
        label.backgroundColor = validateFileName(for: label?.stringValue ?? "") ? .none : errorRed
    }
    func controlTextDidEndEditing(_ obj: Notification) {
        print("File validity: \(validateFileName(for: label?.stringValue ?? ""))")
        label.backgroundColor = validateFileName(for: label?.stringValue ?? "") ? .none : errorRed
        if validateFileName(for: label?.stringValue ?? "") {
            let destinationURL = fileItem.url
                .deletingLastPathComponent()
                .appendingPathComponent(label?.stringValue ?? "")
            delegate?.moveFile(file: fileItem, to: destinationURL)
        } else {
            label?.stringValue = fileItem.fileName
        }
    }

    func validateFileName(for newName: String) -> Bool {
        guard newName != fileItem.fileName else { return true }

        guard newName != "" && newName.isValidFilename &&
              !WorkspaceClient.FileItem.fileManger.fileExists(atPath:
                    fileItem.url.deletingLastPathComponent().appendingPathComponent(newName).path)
        else { return false }

        return true
    }
}

extension String {
    var isValidFilename: Bool {
        let regex = "[^:]"
        let testString = NSPredicate(format: "SELF MATCHES %@", regex)
        return !testString.evaluate(with: self)
    }
}
