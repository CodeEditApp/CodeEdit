//
//  PageAndCEWorkspaceSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation

struct PageAndCEWorkspaceSettings: Identifiable, Equatable {
    let id: UUID = UUID()
    let page: CEWorkspaceSettingsPage
    let settings: [CEWorkspaceSettingsPage]

    init(_ page: CEWorkspaceSettingsPage) {
        self.page = page
        self.settings = CEWorkspaceSettingsData().propertiesOf(page.name)
    }
}
