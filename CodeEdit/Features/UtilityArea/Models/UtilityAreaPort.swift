//
//  UtilityAreaPort.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 4/21/25.
//

import Foundation

/// A forwared port for the UtilityArea
struct UtilityAreaPort: Identifiable, Hashable {
    let id = UUID()
    let address: String
    var label = ""

    var url: URL? {
        URL(string: address)
    }
}
