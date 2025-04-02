//
//  IssueTableViewCell.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/16/25.
//

import AppKit

final class IssueTableViewCell: NSTableCellView {
    private var label: NSTextField!
    private var icon: NSImageView!
    private var secondaryLabel: NSTextField?
    private var node: (any IssueNode)

    let iconWidth: CGFloat = 22

    init(frame: CGRect, node: (any IssueNode)) {
        self.node = node
        super.init(frame: frame)

        // Set up icon
        icon = NSImageView(frame: .zero)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.symbolConfiguration = .init(pointSize: 13, weight: .regular, scale: .medium)

        // Set the icon color based on the type of issue node
        if let projectIssueNode = node as? ProjectIssueNode {
            icon?.image = projectIssueNode.nsIcon
            icon?.contentTintColor = NSColor.folderBlue

            let issuesCount = projectIssueNode.errorCount + projectIssueNode.warningCount
            let pluralizationKey = issuesCount == 1 ? "issue" : "issues"
            createSecondaryLabel(value: "\(issuesCount) \(pluralizationKey)")
        } else if let fileIssueNode = node as? FileIssueNode {
            icon?.image = fileIssueNode.nsIcon
            if Settings.shared.preferences.general.fileIconStyle == .color {
                icon?.contentTintColor = NSColor(fileIssueNode.iconColor)
            } else {
                icon?.contentTintColor = NSColor.coolGray
            }
        } else if let diagnosticNode = node as? DiagnosticIssueNode {
            icon?.image = diagnosticNode.nsIcon
                .withSymbolConfiguration(
                    NSImage.SymbolConfiguration(paletteColors: [.white, diagnosticNode.severityColor])
                )
            icon?.contentTintColor = diagnosticNode.severityColor
        }

        self.addSubview(icon)
        self.imageView = icon

        createLabel()
        setConstraints()
    }

    func createLabel() {
        if let diagnosticNode = node as? DiagnosticIssueNode {
            label = NSTextField(wrappingLabelWithString: diagnosticNode.name)
        } else {
            label = NSTextField(labelWithString: node.name)
        }

        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.layer?.cornerRadius = 10.0
        label.font = .labelFont(ofSize: fontSize)

        if node is DiagnosticIssueNode {
            label.maximumNumberOfLines = Settings.shared.preferences.general.issueNavigatorDetail.rawValue
            label.allowsDefaultTighteningForTruncation = false
            label.cell?.truncatesLastVisibleLine = true
            label.cell?.wraps = true
            label.preferredMaxLayoutWidth = frame.width
        } else {
            label.lineBreakMode = .byTruncatingTail
        }

        self.addSubview(label)
        self.textField = label
    }

    func createSecondaryLabel(value: String) {
        let secondaryLabel = NSTextField(frame: .zero)
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.drawsBackground = false
        secondaryLabel.isBordered = false
        secondaryLabel.isEditable = false
        secondaryLabel.isSelectable = false
        secondaryLabel.layer?.cornerRadius = 10.0
        secondaryLabel.font = .systemFont(ofSize: fontSize)
        secondaryLabel.alignment = .center
        secondaryLabel.textColor = .secondaryLabelColor
        secondaryLabel.stringValue = value

        self.addSubview(secondaryLabel)
        self.secondaryLabel = secondaryLabel
    }

    func setConstraints() {
        if node is DiagnosticIssueNode {
            // For diagnostic nodes, place icon at the top
            NSLayoutConstraint.activate([
                icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                icon.topAnchor.constraint(equalTo: topAnchor, constant: 4),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16),

                label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
            ])
        } else if let secondaryLabel = secondaryLabel {
            // Secondary label
            NSLayoutConstraint.activate([
                icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                icon.centerYAnchor.constraint(equalTo: centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16),

                label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),
                label.centerYAnchor.constraint(equalTo: centerYAnchor),

                secondaryLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 4),
                secondaryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                secondaryLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
            ])
        } else {
            // All other nodes
            NSLayoutConstraint.activate([
                icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                icon.centerYAnchor.constraint(equalTo: centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16),

                label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 4),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                label.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }

    override func layout() {
        super.layout()

        if node is DiagnosticIssueNode {
            let availableWidth = frame.width
            label.preferredMaxLayoutWidth = availableWidth
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
