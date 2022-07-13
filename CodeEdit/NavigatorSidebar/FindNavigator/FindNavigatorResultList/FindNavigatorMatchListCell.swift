//
//  FindNavigatorListCell.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/7/22.
//

import SwiftUI
import WorkspaceClient
import Search

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
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 2),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -2),
            icon.topAnchor.constraint(equalTo: label.topAnchor, constant: 4),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    /// Sets up the `NSTextField` used as a label in the cell.
    /// - Parameter frame: The frame the cell should use.
    private func setUpLabel() {
        self.label = NSTextField(wrappingLabelWithString: matchItem.lineContent ?? "")
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.drawsBackground = false
        self.label.isEditable = false
        self.label.isSelectable = false
        self.label.layer?.cornerRadius = 10.0
        self.label.lineBreakMode = .byTruncatingTail
        self.label.font = .labelFont(ofSize: 13)
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
        if let lineContent = matchItem.lineContent,
           let keywordRange = matchItem.keywordRange {
            /// By default `NSTextView` will ignore any paragraph wrapping set to the label when it's
            /// using an `NSAttributedString` so we need to set the wrap mode here.
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byCharWrapping

            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 13,
                                         weight: .regular),
                .foregroundColor: NSColor.secondaryLabelColor,
                .paragraphStyle: paragraphStyle
            ]
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 13,
                                         weight: .bold),
                .foregroundColor: NSColor.labelColor,
                .paragraphStyle: paragraphStyle
            ]

            /// Set up the search result string with the matched search in bold.
            ///
            /// We also limit the result to 120 characters before and after the
            /// match to reduce *massive* results in the search result list, and for
            /// cases where a file may be formatted in one line (eg: a minimized JS file).
            let lowerIndex = lineContent.index(keywordRange.lowerBound,
                                               offsetBy: -120,
                                               limitedBy: lineContent.startIndex) ?? lineContent.startIndex
            let upperIndex = lineContent.index(keywordRange.upperBound,
                                               offsetBy: 120,
                                               limitedBy: lineContent.endIndex) ?? lineContent.endIndex
            let attributedString = NSMutableAttributedString(
                string: String(lineContent[lowerIndex..<keywordRange.lowerBound]),
                attributes: normalAttributes)
            attributedString.append(NSAttributedString(
                string: String(lineContent[keywordRange.lowerBound..<keywordRange.upperBound]),
                attributes: boldAttributes))
            attributedString.append(NSAttributedString(
                string: String(lineContent[keywordRange.upperBound..<upperIndex]),
                attributes: normalAttributes))

            self.label.attributedStringValue = attributedString
        } else {
            /// If, for some reason, there's no string match we just set the label to an empty string
            /// Realistically this shouldn't happen.
            self.label.stringValue = ""
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
