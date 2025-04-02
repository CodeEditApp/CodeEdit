//
//  IssueTableViewCell.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/16/25.
//

import AppKit

class IssueTableViewCell: StandardTableViewCell {

    private var nodeIconView: NSImageView?

    var issueNode: (any IssueNode)?

    /// Initializes the `IssueTableViewCell` with the issue node item
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - node: The issue node the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the name (rarely used for issues).
    init(frame frameRect: NSRect, node: (any IssueNode)?, isEditable: Bool = false) {
        super.init(frame: frameRect, isEditable: isEditable)
        self.issueNode = node

        configureForNode(node)
    }

    override func configLabel(label: NSTextField, isEditable: Bool) {
        super.configLabel(label: label, isEditable: isEditable)

        if issueNode is DiagnosticIssueNode {
            label.maximumNumberOfLines = 4
            label.lineBreakMode = .byTruncatingTail
            label.cell?.wraps = true
            label.cell?.isScrollable = false
            label.preferredMaxLayoutWidth = frame.width - iconWidth - 20
        } else {
            label.lineBreakMode = .byTruncatingTail
        }
    }

    override func configSecondaryLabel(secondaryLabel: NSTextField) {
        super.configSecondaryLabel(secondaryLabel: secondaryLabel)
        secondaryLabel.font = .systemFont(ofSize: fontSize-2, weight: .medium)
    }

    func configureForNode(_ node: (any IssueNode)?) {
        guard let node = node else { return }

        secondaryLabelRightAligned = true
        textField?.stringValue = node.name

        if let projectIssueNode = node as? ProjectIssueNode {
            imageView?.image = projectIssueNode.nsIcon
            imageView?.contentTintColor = NSColor.folderBlue
        } else if let fileIssueNode = node as? FileIssueNode {
            imageView?.image = fileIssueNode.nsIcon
            if Settings.shared.preferences.general.fileIconStyle == .color {
                imageView?.contentTintColor = NSColor(fileIssueNode.iconColor)
            } else {
                imageView?.contentTintColor = NSColor.coolGray
            }
        } else if let diagnosticNode = node as? DiagnosticIssueNode {
            imageView?.image = diagnosticNode.nsIcon
                .withSymbolConfiguration(
                    NSImage.SymbolConfiguration(paletteColors: [.white, diagnosticNode.severityColor])
                )
            imageView?.contentTintColor = diagnosticNode.severityColor
        }

        if let projectNode = node as? ProjectIssueNode {
            let issuesCount = projectNode.errorCount + projectNode.warningCount

            if issuesCount > 0 {
                secondaryLabelRightAligned = false
                secondaryLabel?.stringValue = "\(issuesCount) issues"
            }
        }
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

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) isn't implemented on `IssueTableViewCell`.")
    }
}
