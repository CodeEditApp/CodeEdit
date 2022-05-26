//
//  CommandPaletteState.swift
//  CodeEdit
//
//  Created by Alex on 25.05.2022.
//

import Foundation
import Keybindings

public final class CommandPaletteState: ObservableObject {
    @Published var commandQuery: String = ""
    @Published var isShowingCommandsList: Bool = true

    func fetchMatchingCommands() {
    }
}
