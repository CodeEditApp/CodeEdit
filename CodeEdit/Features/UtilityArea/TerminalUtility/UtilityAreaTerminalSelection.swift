//
//  UtilityAreaTerminalSelection.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2023-12-25.
//

import CoreTransferable

enum UtilityAreaTerminalSelection: Hashable {
    case group(TerminalGroup)
    case terminal(TerminalEmulator)
}
