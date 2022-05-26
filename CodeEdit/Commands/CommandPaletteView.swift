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
    @State private var selectedItem: Command?
    private let closePalette: () -> Void

    public init(state: CommandPaletteState, closePalette: @escaping () -> Void) {
        self.state = state
        self.closePalette = closePalette
    }

    func callHandler(command: Command) {
        closePalette()
        command.closureWrapper.call()
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "command")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 12)
                        .offset(x: 0, y: 1)
                    TextField("Search Commands", text: $state.commandQuery)
                        .font(.system(size: 20, weight: .light, design: .default))
                        .textFieldStyle(.plain)
                        .onReceive(
                            state.$commandQuery
                                .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
                        ) { val in
                            print(val)
                            state.fetchMatchingCommands()
                        }
                }
                    .padding(16)
                    .foregroundColor(Color(.systemGray).opacity(0.85))
                    .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
//            Divider()
            List {
                ForEach(commandManager.commands) { command in
                    HStack(alignment: .center, spacing: 0) {
                        // swiftlint:disable:next multiple_closures_with_trailing_closure
                        Button(action: { callHandler(command: command) }) {
                            Text(command.title).foregroundColor(Color.white)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .buttonStyle(PlainButtonStyle())
                        .padding(5)
                        .background(Color(.systemBlue))

                    }.frame(maxWidth: .infinity)

                }
            }
//                List(state.commands.values, id: \.id) { file in
//                    NavigationLink(tag: file, selection: $selectedItem) {
//
//                    } label: {
//
//                    }
//                    .onTapGesture(count: 2) {
//                        self.openFile(file)
//                        self.onClose()
//                    }
//                    .onTapGesture(count: 1) {
//                        self.selectedItem = file
//                    }
//                }
//                .frame(minWidth: 250, maxWidth: 250)

        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
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
