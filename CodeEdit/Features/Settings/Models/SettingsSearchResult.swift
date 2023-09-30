//
//  SettingsSearchResult.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 17/06/23.
//

import Foundation
import SwiftUI

// TODO: Extend this struct further to support setting "flashing"
class SettingsSearchResult: Identifiable {
    init(
        pageFound: Bool,
        pages: [SettingsPage]
    ) {
        self.pageFound = pageFound
        self.pages = pages
    }

    let id: UUID = UUID()

    let pageFound: Bool
    let pages: [SettingsPage]
}
