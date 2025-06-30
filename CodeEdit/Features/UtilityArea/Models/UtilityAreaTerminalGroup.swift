//
//  UtilityAreaTerminalGroup.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 30/06/25.
//

import Foundation

struct UtilityAreaTerminalGroup: Identifiable, Hashable {
    var id = UUID()
    var name: String = "Grupo"
    var terminals: [UtilityAreaTerminal] = []
    var isCollapsed: Bool = false
    var userName: Bool = false

    static func == (lhs: UtilityAreaTerminalGroup, rhs: UtilityAreaTerminalGroup) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
