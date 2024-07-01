//
//  CEWorkpaceSettingsSearchResult.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI

// TODO: Extend this struct further to support setting "flashing"
final class CEWorkspaceSettingsSearchResult: Identifiable {
    let id: UUID = UUID()
    let pageFound: Bool
    let pages: [CEWorkspaceSettingsPage]

    init(
        pageFound: Bool,
        pages: [CEWorkspaceSettingsPage]
    ) {
        self.pageFound = pageFound
        self.pages = pages
    }
}
