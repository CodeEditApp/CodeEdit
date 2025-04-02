//
//  IssueTableViewCell.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/16/25.
//

import SwiftUI
import AppKit

class IssueTableViewCell: StandardTableViewCell {

    private var nodeIconView: NSImageView?
    private var detailLabel: NSTextField?

    var issueNode: (any IssueNode)?

    /// Initializes the `IssueTableViewCell` with the issue node item
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - node: The issue node the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the name (rarely used for issues).
    init(frame frameRect: NSRect, node: (any IssueNode)?, isEditable: Bool = false) {
        super.init(frame: frameRect, isEditable: isEditable)
        self.issueNode = node

        secondaryLabelRightAligned = false
        configureForNode(node)
    }

    override func configLabel(label: NSTextField, isEditable: Bool) {
        super.configLabel(label: label, isEditable: isEditable)
        label.lineBreakMode = .byTruncatingTail
    }

    override func createIcon() -> NSImageView {
        let icon = super.createIcon()
        if let diagnosticNode = issueNode as? DiagnosticIssueNode {
            icon.contentTintColor = diagnosticNode.severityColor
        }
        return icon
    }

    func configureForNode(_ node: (any IssueNode)?) {
        guard let node = node else { return }

        textField?.stringValue = node.name

        if let fileIssueNode = node as? FileIssueNode {
            imageView?.image = fileIssueNode.nsIcon
        } else if let diagnosticNode = node as? DiagnosticIssueNode {
            imageView?.image = diagnosticNode.icon
            imageView?.contentTintColor = diagnosticNode.severityColor
        }

        if let diagnosticNode = node as? DiagnosticIssueNode {
            setupDetailLabel(with: diagnosticNode.locationString)
        } else if let projectNode = node as? ProjectIssueNode {
            let issuesCount = projectNode.errorCount + projectNode.warningCount

            if issuesCount > 0 {
                secondaryLabel?.stringValue = "\(issuesCount) issues"
            }
        }
    }

    private func setupDetailLabel(with text: String) {
        detailLabel?.removeFromSuperview()

        let detail = NSTextField(labelWithString: text)
        detail.translatesAutoresizingMaskIntoConstraints = false
        detail.drawsBackground = false
        detail.isBordered = false
        detail.font = .systemFont(ofSize: fontSize-2)
        detail.textColor = .secondaryLabelColor

        addSubview(detail)
        detailLabel = detail
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
