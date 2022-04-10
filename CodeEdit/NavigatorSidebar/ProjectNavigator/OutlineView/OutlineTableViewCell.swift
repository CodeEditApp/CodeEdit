//
//  OutlineTableViewCell.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI

/// A `NSTableCellView` showing an ``icon`` and a ``label``
class OutlineTableViewCell: NSTableCellView {

    var label: NSTextField!
    var icon: NSImageView!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // Create the label

        self.label = NSTextField(frame: .zero)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.drawsBackground = false
        self.label.isBordered = false
        self.label.isEditable = false
        self.label.font = .preferredFont(forTextStyle: .subheadline)

        self.addSubview(label)
        self.textField = label

        // Create the icon

        self.icon = NSImageView(frame: .zero)
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.icon.symbolConfiguration = .init(textStyle: .subheadline, scale: .medium)

        self.addSubview(icon)
        self.imageView = icon

        // Icon constraints

        self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.widthAnchor.constraint(equalToConstant: 21).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: frameRect.height).isActive = true

        // Label constraints

        self.label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 3).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

}
