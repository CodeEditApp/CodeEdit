//
//  QuickSearchResultLabel.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/7/2.
//

import SwiftUI

/// Implementation of command palette entity. While swiftui does not allow to use NSMutableAttributeStrings,
/// the only way to fallback to UIKit and have NSViewRepresentable to be a bridge between UIKit and SwiftUI.
/// Highlights currently entered text query
struct QuickSearchResultLabel: NSViewRepresentable {
    var labelName: String
    var textToMatch: String

    public func makeNSView(context: Context) -> some NSTextField {
        let label = NSTextField(wrappingLabelWithString: labelName)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.textColor = .labelColor
        label.isEditable = false
        label.isSelectable = false
        label.font = .labelFont(ofSize: 13)
        label.allowsDefaultTighteningForTruncation = false
        label.cell?.truncatesLastVisibleLine = true
        label.cell?.wraps = true
        label.maximumNumberOfLines = 1
        label.attributedStringValue = highlight()
        return label
    }

    func highlight() -> NSAttributedString {
        let attribText = NSMutableAttributedString(string: self.labelName)
        let range: NSRange = attribText.mutableString.range(
            of: self.textToMatch,
            options: NSString.CompareOptions.caseInsensitive
        )
        attribText.addAttribute(.foregroundColor, value: NSColor(Color(.labelColor)), range: range)
        attribText.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize), range: range)

        return attribText
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.textColor = textToMatch.isEmpty ? .labelColor : .secondaryLabelColor
        nsView.attributedStringValue = highlight()
    }
}
