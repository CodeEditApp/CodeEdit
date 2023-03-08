//
//  Environment+ActiveTabGroup.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 06/03/2023.
//

import SwiftUI

struct ActiveTabGroupEnvironmentKey: EnvironmentKey {
    static var defaultValue = false
}

extension EnvironmentValues {
    var isActiveTabGroup: Bool {
        get { self[ActiveTabGroupEnvironmentKey.self] }
        set { self[ActiveTabGroupEnvironmentKey.self] = newValue }
    }
}
