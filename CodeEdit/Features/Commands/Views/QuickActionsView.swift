//
//  CommandPaletteView.swift
//  CodeEdit
//
//  Created by Alex Sinelnikov on 24.05.2022.
//

import SwiftUI

/// Quick actions view
struct QuickActionsView: View {

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @ObservedObject private var state: QuickActionsViewModel

    @ObservedObject private var commandManager: CommandManager = .shared

    @State private var monitor: Any?

    @State private var selectedItem: Command?

    private let closePalette: () -> Void

    init(state: QuickActionsViewModel, closePalette: @escaping () -> Void) {
        self.state = state
        self.closePalette = closePalette
        state.filteredCommands = commandManager.commands
    }

    func callHandler(command: Command) {
        closePalette()
        command.closureWrapper.call()
        selectedItem = nil
        state.commandQuery = ""
        state.filteredCommands = []
    }

    func onQueryChange(text: String) {
        state.commandQuery = text
        state.fetchMatchingCommands(val: text)
    }

    var body: some View {
        SearchPanelView<SearchResultLabel, EmptyView, Command>(
            title: "Commands",
            image: Image(systemName: "magnifyingglass"),
            options: $state.filteredCommands,
            text: $state.commandQuery,
            alwaysShowOptions: true,
            optionRowHeight: 30
        ) { command in
            SearchResultLabel(labelName: command.title, textToMatch: state.commandQuery)
        } onRowClick: { command in
            callHandler(command: command)
        } onClose: {
            closePalette()
        }
        .onReceive(state.$commandQuery.debounce(for: 0.2, scheduler: DispatchQueue.main)) { _ in
            state.fetchMatchingCommands(val: state.commandQuery)
        }
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
