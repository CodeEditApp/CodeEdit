//
//  SettingPageView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/31/23.
//

import SwiftUI

struct SettingsPageView: View {
    var page: SettingsPage
    var searchText: String

    init(_ page: SettingsPage, searchText: String) {
        self.page = page
        self.searchText = searchText
    }

    var symbol: Image? {
        switch page.icon {
        case .system(let name):
            Image(systemName: name)
        case .symbol(let name):
            Image(symbol: name)
        case .asset(let name):
            Image(name)
        case .none: nil
        }
    }

    var body: some View {
        NavigationLink(value: page) {
            Label {
                page.name.rawValue.highlightOccurrences(self.searchText)
                    .padding(.leading, 2)
            } icon: {
                FeatureIcon(symbol: symbol, color: page.baseColor, size: 20)
            }
        }
    }
}
