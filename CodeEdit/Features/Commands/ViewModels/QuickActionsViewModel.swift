//
//  CommandPaletteViewModel.swift
//  CodeEdit
//
//  Created by Alex on 25.05.2022.
//

import SwiftUI

/// Simple state class for command palette view. Contains currently selected command,
/// query text and list of filtered commands
final class QuickActionsViewModel: ObservableObject {

    @Published var commandQuery: String = ""

    @Published var selected: Command?

    @Published var isShowingCommandsList: Bool = true

    @Published var filteredCommands: [Command] = []

    init() {}

    func reset() {
        commandQuery = ""
        selected = nil
        filteredCommands = CommandManager.shared.commands
    }

    func fetchMatchingCommands(val: String) {
        if val == "" {
            self.filteredCommands = CommandManager.shared.commands
            return
        }
        self.filteredCommands = CommandManager.shared.commands.filter { $0.title.localizedCaseInsensitiveContains(val) }
        self.selected = self.filteredCommands.first
    }

    func highlight(_ commandTitle: String) -> NSAttributedString {
        let attribText = NSMutableAttributedString(string: commandTitle)
        let range: NSRange = attribText.mutableString.range(
            of: self.commandQuery,
            options: NSString.CompareOptions.caseInsensitive
        )
        attribText.addAttribute(.foregroundColor, value: NSColor(Color(.labelColor)), range: range)
        attribText.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize), range: range)

        return attribText
    }

}
