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

    private var iconName: String {
        switch page.icon {
        case .system(let name), .symbol(let name):
            return name
        case .asset(let name):
            return name
        case .none:
            return "questionmark.circle" // fallback icon
        }
    }

    var body: some View {
        NavigationLink(value: page) {
            Label {
                page.name.rawValue.highlightOccurrences(self.searchText)
                    .padding(.leading, 2)
            } icon: {
                if case .asset(let name) = page.icon {
                    FeatureIcon(image: Image(name), size: 20)
                } else {
                    FeatureIcon(symbol: iconName, color: page.baseColor, size: 20)
                }
            }
        }
    }
}
