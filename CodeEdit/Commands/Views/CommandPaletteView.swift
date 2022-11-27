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
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "command")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(.leading, 20)
                        .offset(x: 0, y: 1)
                    ActionAwareInput(text: $state.commandQuery, onDown: onKeyDown,
                                     onTextChange: onQueryChange)
                        .font(.system(size: 24, weight: .light, design: .default))
                        .padding(16)
                        .frame(height: 52, alignment: .center)
                        .foregroundColor(Color(.systemGray).opacity(0.85))
                        .background(EffectView(.sidebar, blendingMode: .behindWindow))
                }

            Divider()
            VStack(spacing: 0) {
                List(commandsList, selection: $state.selected) { command in
                    // swiftlint:disable multiple_closures_with_trailing_closure
                    Button(action: { onCommandClick(command: command) }) {
                        VStack {
                            SearchResultLabel(labelName: command.title,
                                              textToMatch: state.commandQuery,
                                              fontColor: textColor(command: command))
                            .padding(.zero)
                        }.frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                    }.frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 0))
                        .buttonStyle(.borderless)
                        .background(self.selectedItem == command ?
                                           RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color(red: 0, green: 0.38, blue: 0.816, opacity: 0.85)) :
                                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color.clear))
                        .onHover(perform: { _ in self.selectedItem = command })
                    }.listStyle(SidebarListStyle())

            }
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .foregroundColor(.gray)
        .edgesIgnoringSafeArea(.vertical)
        .frame(minWidth: 600,
           minHeight: self.state.isShowingCommandsList ? 400 : 28,
           maxHeight: self.state.isShowingCommandsList ? .infinity : 28)
    }
}

struct CommandPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        CommandPaletteView(
            state: .init(),
            closePalette: {}
        )
    }
}

class ActionAwareInputView: NSTextView, NSTextFieldDelegate {

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

}

/// Implementation of command palette entity. While swiftui does not allow to use NSMutableAttributeStrings,
/// the only way to fallback to UIKit and have NSViewRepresentable to be a bridge between UIKit and SwiftUI.
/// Highlights currently entered text query

struct SearchResultLabel: NSViewRepresentable {

    var labelName: String
    var textToMatch: String
    var fontColor: Color

    public func makeNSView(context: Context) -> some NSTextField {
        let label = NSTextField(wrappingLabelWithString: labelName)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.drawsBackground = false
        label.textColor = NSColor(fontColor.opacity(0.55))
        label.isEditable = false
        label.isSelectable = false
        label.layer?.cornerRadius = 10.0
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
        let range: NSRange = attribText.mutableString.range(of: self.textToMatch,
                                                                options: NSString.CompareOptions.caseInsensitive)
        attribText.addAttribute(.foregroundColor, value: NSColor(fontColor.opacity(0.85)), range: range)

        return attribText
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.textColor = NSColor(fontColor.opacity(0.55))
        nsView.attributedStringValue = highlight()
    }

}

/// A special NSTextView based input that allows to override onkeyDown events and add according handlers.
/// Very useful when need to use arrows to navigate through the list of items that matches entered text
struct ActionAwareInput: NSViewRepresentable {

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

        return input
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.textContainer?.textView?.string = text
        // This way we can update light/dark mode font color
        nsView.textContainer?.textView?.textColor = NSColor(fontColor)
    }
}
