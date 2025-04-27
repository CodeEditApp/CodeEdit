//
//  IssueTableViewCell.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/16/25.
//

import AppKit

final class IssueTableViewCell: StandardTableViewCell {
    private var node: (any IssueNode)

    init(frame: CGRect, node: (any IssueNode)) {
        self.node = node
        super.init(frame: frame)

        // Set the icon based on the node type
        if let projectIssueNode = node as? ProjectIssueNode {
            imageView?.image = projectIssueNode.nsIcon
            imageView?.contentTintColor = NSColor.folderBlue

            let issuesCount = projectIssueNode.errorCount + projectIssueNode.warningCount
            let pluralizationKey = issuesCount == 1 ? "issue" : "issues"
            secondaryLabel?.stringValue = "\(issuesCount) \(pluralizationKey)"
        } else if let fileIssueNode = node as? FileIssueNode {
            imageView?.image = fileIssueNode.nsIcon
            if Settings.shared.preferences.general.fileIconStyle == .color {
                imageView?.contentTintColor = NSColor(fileIssueNode.iconColor)
            } else {
                imageView?.contentTintColor = NSColor.coolGray
            }
        } else if let diagnosticNode = node as? DiagnosticIssueNode {
            imageView?.image = diagnosticNode.nsIcon.withSymbolConfiguration(
                NSImage.SymbolConfiguration(paletteColors: [.white, diagnosticNode.severityColor])
            )
            imageView?.image?.isTemplate = false
        }

        textField?.stringValue = node.name
        secondaryLabelRightAligned = false
    }

    override func createLabel() -> NSTextField {
        if let diagnosticNode = node as? DiagnosticIssueNode {
            return NSTextField(wrappingLabelWithString: diagnosticNode.name)
        } else {
            return NSTextField(labelWithString: node.name)
        }
    }

    override func configLabel(label: NSTextField, isEditable: Bool) {
        super.configLabel(label: label, isEditable: false)

        if node is DiagnosticIssueNode {
            label.maximumNumberOfLines = Settings.shared.preferences.general.issueNavigatorDetail.rawValue
            label.allowsDefaultTighteningForTruncation = false
            label.cell?.truncatesLastVisibleLine = true
            label.cell?.wraps = true
            label.preferredMaxLayoutWidth = frame.width - iconWidth - 10
        } else {
            label.lineBreakMode = .byTruncatingTail
        }
    }

    override func createConstraints(frame frameRect: NSRect) {
        super.createConstraints(frame: frameRect)
        guard let imageView,
              let textField = self.textField,
              node is DiagnosticIssueNode
        else { return }

        // table views can autosize constraints
        // https://developer.apple.com/documentation/appkit/nsoutlineview/autoresizesoutlinecolumn
        // https://developer.apple.com/documentation/appkit/nstableview/usesautomaticrowheights

        // For diagnostic nodes, place icon at the top
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18),

            textField.leadingAnchor
                .constraint(equalTo: imageView.trailingAnchor, constant: 6),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 4),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)

        if node is DiagnosticIssueNode {
            textField?.preferredMaxLayoutWidth = frame.width - iconWidth - 10
        }
    }
}
