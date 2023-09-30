//
//  PageAndSettings.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 10/07/23.
//

import Foundation

struct PageAndSettings: Identifiable, Equatable {
    let id: UUID = UUID()
    let page: SettingsPage
    let settings: [SettingsPage]

    init(_ page: SettingsPage) {
        self.page = page
        self.settings = SettingsData().propertiesOf(page.name)
    }
}
