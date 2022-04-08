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

        let iconHeight = frameRect.height - 2

        // Create the label

        self.label = NSTextField(frame: .zero)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.drawsBackground = false
        self.label.isBordered = false
        self.label.isEditable = false

        self.addSubview(label)
        self.textField = label

        // Create the icon

        self.icon = NSImageView(frame: .init(origin: .zero, size: .zero))
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.icon.symbolConfiguration = .init(pointSize: 13, weight: .regular, scale: .medium)
        self.icon.imageScaling = .scaleProportionallyDown

        self.addSubview(icon)
        self.imageView = icon

        // Icon constraints

        self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.widthAnchor.constraint(equalToConstant: iconHeight).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true

        // Label constraints

        self.label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 5).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

}
