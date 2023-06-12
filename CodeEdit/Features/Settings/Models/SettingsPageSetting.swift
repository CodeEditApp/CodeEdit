//
//  SettingsPageSetting.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 12/06/23.
//

import Foundation

struct SettingsPageSetting: Hashable, Equatable, Identifiable {
    internal init(
        nameString: String
    ) {
        self.nameString = nameString
    }

    var id = UUID()
    var nameString: String
}
