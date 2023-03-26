//
//  StandardTableViewCell.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

class StandardTableViewCell: NSTableCellView {

    var label: NSTextField!
    var secondaryLabel: NSTextField!
    var icon: NSImageView!

    var workspace: WorkspaceDocument?

    var secondaryLabelRightAlignmed: Bool = true {
        didSet {
            resizeSubviews(withOldSize: .zero)
        }
    }

    private let prefs = AppPreferencesModel.shared.preferences.general

    /// Initializes the `TableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - item: The file item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    init(frame frameRect: NSRect, isEditable: Bool = true) {
        super.init(frame: frameRect)
        setupViews(frame: frameRect, isEditable: isEditable)
    }

    // Default init, assumes isEditable to be false
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews(frame: frameRect, isEditable: false)
    }

    private func setupViews(frame frameRect: NSRect, isEditable: Bool) {
        // Create the label
        label = createLabel()
        configLabel(label: self.label, isEditable: isEditable)
        self.textField = label

        // Create the secondary label
        secondaryLabel = createSecondaryLabel()
        configSecondaryLabel(secondaryLabel: secondaryLabel)

        // Create the icon
        icon = createIcon()
        configIcon(icon: icon)
        addSubview(icon)
        imageView = icon

        // add constraints
        createConstraints(frame: frameRect)
        addSubview(label)
        addSubview(secondaryLabel)
        addSubview(icon)
    }

    // MARK: Create and config stuff
    func createLabel() -> NSTextField {
        return SpecialSelectTextField(frame: .zero)
    }

    func configLabel(label: NSTextField, isEditable: Bool) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isBordered = false
        label.isEditable = isEditable
        label.isSelectable = isEditable
        label.layer?.cornerRadius = 10.0
        label.font = .labelFont(ofSize: fontSize)
        label.lineBreakMode = .byTruncatingMiddle
    }

    func createSecondaryLabel() -> NSTextField {
        return NSTextField(frame: .zero)
    }

    func configSecondaryLabel(secondaryLabel: NSTextField) {
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.drawsBackground = false
        secondaryLabel.isBordered = false
        secondaryLabel.isEditable = false
        secondaryLabel.isSelectable = false
        secondaryLabel.layer?.cornerRadius = 10.0
        secondaryLabel.font = .systemFont(ofSize: fontSize)
        secondaryLabel.alignment = .center
        secondaryLabel.textColor = NSColor(Color.secondary)
    }

    func createIcon() -> NSImageView {
        return NSImageView(frame: .zero)
    }

    func configIcon(icon: NSImageView) {
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.symbolConfiguration = .init(pointSize: fontSize, weight: .regular, scale: .medium)
    }

    func createConstraints(frame frameRect: NSRect) {
        resizeSubviews(withOldSize: .zero)
    }

    let iconWidth: CGFloat = 22
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)

        icon.frame = NSRect(x: 2, y: 4,
                            width: iconWidth, height: frame.height)
        // center align the image
        if let alignmentRect = icon.image?.alignmentRect {
            icon.frame = NSRect(x: (iconWidth + 4 - alignmentRect.width) / 2, y: 4,
                                width: alignmentRect.width, height: frame.height)
        }

        // right align the secondary label
        if secondaryLabelRightAlignmed {
            let secondLabelWidth = secondaryLabel.frame.size.width
            let newSize = secondaryLabel.sizeThatFits(CGSize(width: secondLabelWidth,
                                                             height: CGFloat.greatestFiniteMagnitude))
            // somehow, a width of 0 makes it resize properly.
            secondaryLabel.frame = NSRect(x: frame.width - newSize.width, y: 2.5,
                                          width: 0, height: newSize.height)

            label.frame = NSRect(x: iconWidth + 2, y: 2.5,
                                 width: secondaryLabel.frame.minX - icon.frame.maxX - 5, height: 25)

        // put the secondary label right after the primary label
        } else {
            let mainLabelWidth = label.frame.size.width
            let newSize = label.sizeThatFits(CGSize(width: mainLabelWidth,
                                                    height: CGFloat.greatestFiniteMagnitude))
            label.frame = NSRect(x: iconWidth + 2, y: 2.5,
                                 width: newSize.width, height: 25)
            secondaryLabel.frame = NSRect(x: label.frame.maxX + 2, y: 2.5,
                                          width: frame.width - label.frame.maxX - 2, height: 25)
        }
    }

    /// *Not Implemented*
    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `StandardTableViewCell`.
            Please use `.init(frame: NSRect, isEditable: Bool)
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

    class SpecialSelectTextField: NSTextField {
//        override func becomeFirstResponder() -> Bool {
            // TODO: Set text range
            // this is the code to get the text range, however I cannot find a way to select it :(
//            NSRange(location: 0, length: stringValue.distance(from: stringValue.startIndex,
//                to: stringValue.lastIndex(of: ".") ?? stringValue.endIndex))
//            return true
//        }
    }
}
