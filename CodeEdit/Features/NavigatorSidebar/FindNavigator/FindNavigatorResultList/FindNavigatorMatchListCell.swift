//
//  FindNavigatorListCell.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/7/22.
//

import SwiftUI

/// A `NSTableCellView` showing an icon and label
final class FindNavigatorListMatchCell: NSTableCellView {

    private var label: NSTextField!
    private var icon: NSImageView!
    private var matchItem: SearchResultMatchModel

    init(frame: CGRect, matchItem: SearchResultMatchModel) {
        self.matchItem = matchItem
        super.init(frame: CGRect(x: frame.origin.x,
                                 y: frame.origin.y,
                                 width: frame.width,
                                 height: CGFloat.greatestFiniteMagnitude))

        // Create the label
        setUpLabel()
        setLabelString()

        self.addSubview(label)

        // Create the icon

        setUpImageView()

        self.addSubview(icon)
        self.imageView = icon

        // Constraints

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -2),
            icon.topAnchor.constraint(equalTo: label.topAnchor, constant: 2),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    /// Sets up the `NSTextField` used as a label in the cell.
    /// - Parameter frame: The frame the cell should use.
    private func setUpLabel() {
        self.label = NSTextField(wrappingLabelWithString: matchItem.lineContent)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.drawsBackground = false
        self.label.isEditable = false
        self.label.isSelectable = false
        self.label.layer?.cornerRadius = 10.0
        self.label.font = .labelFont(ofSize: 13)
        self.label.allowsDefaultTighteningForTruncation = false
        self.label.cell?.truncatesLastVisibleLine = true
        self.label.cell?.wraps = true
        self.label.maximumNumberOfLines = 3
    }

    /// Sets up the image view for the search result.
    private func setUpImageView() {
        self.icon = NSImageView(frame: .zero)
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.icon.symbolConfiguration = .init(pointSize: 13,
                                              weight: .regular,
                                              scale: .medium)
        self.icon.image = NSImage(systemSymbolName: "text.alignleft", accessibilityDescription: nil)
        self.icon.contentTintColor = NSColor.secondaryLabelColor
    }

    /// Sets the attributed string for the search result with correct paragraph break mode,
    /// styling, font, etc.
    private func setLabelString() {
        self.label.attributedStringValue = matchItem.attributedLabel()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
