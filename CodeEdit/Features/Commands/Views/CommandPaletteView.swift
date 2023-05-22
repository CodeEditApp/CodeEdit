//
//  CommandPaletteView.swift
//  CodeEdit
//
//  Created by Alex Sinelnikov on 24.05.2022.
//

import SwiftUI

/// Command palette view
struct CommandPaletteView: View {

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @ObservedObject
    private var state: CommandPaletteViewModel

    @State
    private var monitor: Any?

    private let closePalette: () -> Void

    init(state: CommandPaletteViewModel, closePalette: @escaping () -> Void) {
        self.state = state
        self.closePalette = closePalette
    }

    var body: some View {
        OverlayView<CommandPaletteItem, EmptyView, CodeEditCommand>(
            title: "Commands",
            image: Image(systemName: "magnifyingglass"),
            options: $state.filteredMenuCommands,
            text: $state.commandQuery,
            alwaysShowOptions: true,
            optionRowHeight: 30
        ) { command, selected in
            CommandPaletteItem(command: command, textToMatch: state.commandQuery, selected: selected)
        } onRowClick: {
            $0.runAction()
        } onClose: {
            closePalette()
        }
        .onReceive(state.$commandQuery.debounce(for: 0.2, scheduler: DispatchQueue.main)) { _ in
            state.fetchMatchingCommands(filter: state.commandQuery)
        }
    }
}

struct CommandPaletteItem: View {
    let command: CodeEditCommand
    let textToMatch: String?
    let selected: Bool

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                SearchResultLabel(labelName: command.title, textToMatch: textToMatch ?? "")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text(command.shortcut ?? "")
                .foregroundColor(selected ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Implementation of command palette entity. While swiftui does not allow to use NSMutableAttributeStrings,
/// the only way to fallback to UIKit and have NSViewRepresentable to be a bridge between UIKit and SwiftUI.
/// Highlights currently entered text query
struct SearchResultLabel: NSViewRepresentable {
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
