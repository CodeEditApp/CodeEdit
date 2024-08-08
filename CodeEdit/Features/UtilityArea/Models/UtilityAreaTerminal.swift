//
//  UtilityAreaTerminal.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/27/24.
//

import Foundation

final class UtilityAreaTerminal: ObservableObject, Identifiable, Equatable {
    let id: UUID
    @Published var url: URL
    @Published var title: String
    @Published var terminalTitle: String
    @Published var shell: Shell?
    @Published var customTitle: Bool

    init(id: UUID, url: URL, title: String, shell: Shell?) {
        self.id = id
        self.title = title
        self.terminalTitle = title
        self.url = url
        self.shell = shell
        self.customTitle = false
    }

    static func == (lhs: UtilityAreaTerminal, rhs: UtilityAreaTerminal) -> Bool {
        lhs.id == rhs.id
    }
}
