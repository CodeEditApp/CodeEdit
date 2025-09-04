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
    let labelName: String
    let charactersToHighlight: [NSRange]
    let maximumNumberOfLines: Int = 1
    var nsLabelName: NSAttributedString?

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
        label.maximumNumberOfLines = maximumNumberOfLines
        label.attributedStringValue = nsLabelName ?? highlight()
        return label
    }

    func highlight() -> NSAttributedString {
        let attribText = NSMutableAttributedString(string: self.labelName)
        for range in charactersToHighlight {
            attribText.addAttribute(.foregroundColor, value: NSColor.controlTextColor, range: range)
            attribText.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize), range: range)
        }
        return attribText
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.textColor = if nsLabelName == nil && charactersToHighlight.isEmpty {
            .controlTextColor
        } else {
            .secondaryLabelColor
        }
        nsView.attributedStringValue = nsLabelName ?? highlight()
    }
}
