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

    @ObservedObject
    private var commandManager: CommandManager = .shared

    @State
    private var monitor: Any?

    @State
    private var selectedItem: Command?

    private let closePalette: () -> Void

    private var commandsList: [Command] {
        return $state.filteredCommands.wrappedValue.isEmpty && $state.commandQuery.wrappedValue.isEmpty ?
             commandManager.commands : state.filteredCommands
    }

    init(state: CommandPaletteViewModel, closePalette: @escaping () -> Void) {
        self.state = state
        self.closePalette = closePalette
        self.selectedItem = commandsList.first
    }

    func resetState() {
        self.selectedItem = nil
        self.state.commandQuery = ""
    }

    func callHandler(command: Command) {
        closePalette()
        command.closureWrapper.call()
        resetState()
    }

    func selectNext() {
        if commandsList.isEmpty {
            self.selectedItem = nil
            return
        }

        var idx = -1
        if self.selectedItem != nil {
            idx = commandsList.firstIndex(of: self.selectedItem!) ?? -1
        }

        if idx + 1 == commandsList.count {
            idx = -1
        }

        self.selectedItem = commandsList[idx + 1]
    }

    func selectPrev() {
        if commandsList.isEmpty {
            self.selectedItem = nil
            return
        }

        var idx = -1
        if self.selectedItem != nil {
            idx = commandsList.firstIndex(of: self.selectedItem!) ?? -1
        }

        if idx - 1 < 0 {
            idx = commandsList.count
        }

        self.selectedItem = commandsList[idx - 1]
    }

    /// It should return bool value in order to notify underlying handler if event was handled or not.
    /// So returning true - means you need to break the chain and do not pass event down the line
    func onKeyDown(with event: NSEvent) -> Bool {

        switch event.keyCode {
            // down arrow button
        case 125:
            selectNext()
            return true
            // up arrow button
        case 126:
            selectPrev()
            return true
            // enter button
        case 36:
            if let command = self.selectedItem {
                callHandler(command: command)
            }
            return true
            // esc button
        case 53:
            closePalette()
            return true
        default:
            return false
        }
    }

    func onQueryChange(text: String) {
        state.commandQuery = text
        state.fetchMatchingCommands(val: text)
    }

    func onCommandClick(command: Command) {
        self.selectedItem = command
        callHandler(command: command)
    }

    func textColor(command: Command) -> Color {
        if self.selectedItem == command {
            return .white
        }

        return colorScheme == .dark ? .white : .black
    }

    var body: some View {
        VStack(spacing: 0.0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .padding(.leading, 1)
                        .padding(.trailing, 5)

                    ActionAwareInput(
                        text: $state.commandQuery, onDown: onKeyDown,
                        onTextChange: onQueryChange
                    )
                    .font(.system(size: 24, weight: .light, design: .default))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .foregroundColor(.primary)
                .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
            .frame(height: 48)
            Divider()
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(commandsList) { command in
                        // swiftlint:disable multiple_closures_with_trailing_closure
                        Button(action: { onCommandClick(command: command) }) {
                                SearchResultLabel(
                                    labelName: command.title,
                                    textToMatch: state.commandQuery
                                )
                        }
                        .padding(.init(top: 8, leading: 10, bottom: 8, trailing: 8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .buttonStyle(.borderless)
                        .background(
                            Color(self.selectedItem == command ? .selectedContentBackgroundColor : .clear)
                        )
                        .cornerRadius(5)
                        .onHover(perform: { _ in self.selectedItem = command })
                    }
                }
                .padding(8)
            }
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .edgesIgnoringSafeArea(.vertical)
        .frame(
            minWidth: 680,
            minHeight: self.state.isShowingCommandsList ? 400 : 19,
            maxHeight: self.state.isShowingCommandsList ? .infinity : 19
        )
    }
}

private class ActionAwareInputView: NSTextView, NSTextFieldDelegate {

    var onDown: ((NSEvent) -> Bool)?
    var onTextChange: ((String) -> Void)?

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        return true
    }

    override var acceptsFirstResponder: Bool { return true }

    override public func keyDown(with event: NSEvent) {
        if onDown!(event) {
            // We don't want to pass event down the pipe if it was handled.
            // By handled I mean its keycode was used for something else than typing
            return
        }

        super.keyDown(with: event)
    }

    override public func didChangeText() {
        onTextChange?(self.string)
    }

    var placeholderString: String = ""

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if string.isEmpty && !placeholderString.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.placeholderTextColor,
                .font: font ?? NSFont.systemFont(ofSize: 12),
                .paragraphStyle: paragraphStyle
            ]
            let attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: attrs)
            attributedPlaceholder.draw(in: dirtyRect.insetBy(dx: 6, dy: 0))
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
        if textToMatch == "" {
            nsView.textColor = .labelColor
        }
        nsView.attributedStringValue = highlight()
    }

}

/// A special NSTextView based input that allows to override onkeyDown events and add according handlers.
/// Very useful when need to use arrows to navigate through the list of items that matches entered text
private struct ActionAwareInput: NSViewRepresentable {

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var fontColor: Color {
        colorScheme == .dark ? .white : .black
    }

    @Binding
    var text: String

    var onDown: ((NSEvent) -> Bool)?
    var onTextChange: ((String) -> Void)

    func makeNSView(context: Context) -> some NSTextView {
        let input = ActionAwareInputView()
        input.textContainer?.maximumNumberOfLines = 1
        input.onTextChange = onTextChange
        input.string = text
        input.onDown = onDown
        input.font = .systemFont(ofSize: 20, weight: .light)
        input.textColor = NSColor(fontColor)
        input.drawsBackground = false
        input.becomeFirstResponder()
        input.invalidateIntrinsicContentSize()
        input.placeholderString = "Commands"

        return input
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.textContainer?.textView?.string = text
        // This way we can update light/dark mode font color
        nsView.textContainer?.textView?.textColor = NSColor(fontColor)
    }
}
