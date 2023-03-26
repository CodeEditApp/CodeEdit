//
//  TextTableViewCell.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 11/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

class TextTableViewCell: NSTableCellView {

    var label: NSTextField!

    init(frame frameRect: NSRect, isEditable: Bool = true, startingText: String = "") {
        super.init(frame: frameRect)
        setupViews(frame: frameRect, isEditable: isEditable)
        self.label.stringValue = startingText
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

        addSubview(label)
        createConstraints(frame: frameRect)
    }

    // MARK: Create and config stuff
    func createLabel() -> NSTextField {
        return NSTextField(frame: .zero)
    }

    func configLabel(label: NSTextField, isEditable: Bool) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isBordered = false
        label.isEditable = isEditable
        label.isSelectable = isEditable
        label.layer?.cornerRadius = 10.0
        label.font = .boldSystemFont(ofSize: fontSize)
        label.lineBreakMode = .byTruncatingMiddle
        label.textColor = NSColor.textColor
        label.alphaValue = 0.7
    }

    func createConstraints(frame frameRect: NSRect) {
        resizeSubviews(withOldSize: .zero)
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        label.frame = NSRect(x: 2, y: 2.5,
                             width: frame.width - 4, height: 25)
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

    /// *Not Implemented*
    required init(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `TextTableViewCell`.
            Please use `.init(frame: NSRect, isEditable: Bool)
            """)
    }
}
