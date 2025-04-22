//
//  UtilityAreaPort.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 4/21/25.
//

import Foundation

/// A forwared port for the UtilityArea
final class UtilityAreaPort: ObservableObject {
    let id: UUID
    let port: String
    @Published var label: String

    init(id: UUID = UUID(), port: String) {
        self.id = id
        self.port = port
        self.label = ""
    }
}
