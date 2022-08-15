//
//  CommandPaletteView.swift
//  CodeEdit
//
//  Created by Alex on 24.05.2022.
//

import SwiftUI
import Keybindings
import CodeEditUI

public struct CommandPaletteView: View {
    @ObservedObject private var state: CommandPaletteState
    @ObservedObject var commandManager: CommandManager = CommandManager.shared

    @State private var monitor: Any?
    @State private var selectedItem: Command?
    private let closePalette: () -> Void

    public init(state: CommandPaletteState, closePalette: @escaping () -> Void) {
        self.state = state
        self.closePalette = closePalette
        print(commandsList.count)
        print(commandsList[0])
        self.selectedItem = commandManager.commands[0]

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

    var commandsList: [Command] {
        return $state.filteredCommands.wrappedValue.isEmpty && $state.commandQuery.wrappedValue.isEmpty ?
             commandManager.commands : state.filteredCommands
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
        case 125:
            selectNext()
            return true
        case 126:
            selectPrev()
            return true
        case 36:
            if let command = self.selectedItem {
                callHandler(command: command)
            }
            return true
        case 53:
            closePalette()
        default:
            return false
        }

        return false
    }

    func onQueryChange(text: String) {
        state.commandQuery = text
        state.fetchMatchingCommands(val: text)
    }

    func onCommandClick(command: Command) {
        self.selectedItem = command
        callHandler(command: command)
    }

    public var body: some View {
        VStack(spacing: 0.0) {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "command")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(.leading, 20)
                        .offset(x: 0, y: 1)
//                    TextField("Search Commands", text: $state.commandQuery)
//                        .font(.system(size: 20, weight: .light, design: .default))
//                        .textFieldStyle(.plain)
//                        .onReceive(
//                            state.$commandQuery
//                                .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
//                        ) { val in
//                            state.fetchMatchingCommands(val: val)
//                        }.keyboardListener(keys: [126, 125, 53], modifiers: [], onDown: {
//                            print("On down")
//                        })
//                    .padding(16)
//                    .foregroundColor(Color(.systemGray).opacity(0.85))
//                    .background(EffectView(.sidebar, blendingMode: .behindWindow))

                    ActionAwareInput(onDown: onKeyDown,
                                     onTextChange: onQueryChange, text: $state.commandQuery)
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
                            Text(command.title)
                            .padding(EdgeInsets.init(top: 0, leading: 8, bottom: 0, trailing: 0))
                            .foregroundColor(.white)
                        }.frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                    }.frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                        .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(EdgeInsets.init(top: 5, leading: 5, bottom: 5, trailing: 0))
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
        print(commandSelector)
        return true
    }

    override var acceptsFirstResponder: Bool { return true }

    override public func keyDown(with event: NSEvent) {
        print("keydown")
        print(event.keyCode)

        if onDown!(event) {
            return
        }

        super.keyDown(with: event)
    }

    override public func didChangeText() {
        onTextChange?(self.string)
        print(self.string)
    }

}

public struct ActionAwareInput: NSViewRepresentable {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var fontColor: Color {
            colorScheme == .dark ? .white : .black
        }

    var onDown: ((NSEvent) -> Bool)?
    var onTextChange: ((String) -> Void)
    @Binding var text: String

    public func makeNSView(context: Context) -> some NSTextView {
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

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.textContainer?.textView?.string = text
        // This way we can update light/dark mode font color
        nsView.textContainer?.textView?.textColor = NSColor(fontColor)
    }
}
