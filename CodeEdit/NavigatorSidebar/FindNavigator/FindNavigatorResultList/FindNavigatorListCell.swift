//
//  FindNavigatorListCell.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/7/22.
//

import SwiftUI
import WorkspaceClient
import Search

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class FindNavigatorListMatchCell: NSTableCellView {

    private var label: NSTextField!
    private var icon: NSImageView!
    private var matchItem: SearchResultMatchModel

    init(matchItem: SearchResultMatchModel) {
        self.matchItem = matchItem
        super.init(frame: .zero)

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
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -2),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            icon.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 1),
            icon.widthAnchor.constraint(equalToConstant: 25),
            icon.heightAnchor.constraint(equalToConstant: 25),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 1),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1)
        ])
    }

    private func setUpLabel() {
        self.label = NSTextField(frame: .zero)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.drawsBackground = false
        self.label.isBordered = false
        self.label.isEditable = false
        self.label.isSelectable = false
        self.label.layer?.cornerRadius = 10.0
        self.label.font = .labelFont(ofSize: 13)
    }

    private func setUpImageView() {
        self.icon = NSImageView(frame: .zero)
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.icon.symbolConfiguration = .init(pointSize: 13,
                                              weight: .regular,
                                              scale: .medium)
        self.icon.image = NSImage(systemSymbolName: "text.alignleft", accessibilityDescription: nil)
    }

    private func setLabelString() {
        if let lineContent = matchItem.lineContent,
           let keywordRange = matchItem.keywordRange {
            let attributedString = NSMutableAttributedString(
                string: String(lineContent[lineContent.startIndex..<keywordRange.lowerBound]),
                attributes: [
                    .font: NSFont.systemFont(ofSize: 12,
                                             weight: .regular)
                ])
            attributedString.append(NSAttributedString(
                string: String(lineContent[keywordRange.lowerBound..<keywordRange.upperBound]),
                attributes: [
                    .font: NSFont.systemFont(ofSize: 12,
                                             weight: .bold)
                ]))
            attributedString.append(NSAttributedString(
                string: String(lineContent[keywordRange.upperBound..<lineContent.endIndex]),
                attributes: [
                    .font: NSFont.systemFont(ofSize: 12,
                                             weight: .regular)
                ]))

            self.label.attributedStringValue = attributedString
        } else {
            self.label.stringValue = ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
