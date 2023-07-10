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

    var body: some View {
        NavigationLink(value: page) {
            Label {
                page.name.rawValue.highlightOccurrences(self.searchText)
                    .padding(.leading, 2)
            } icon: {
                Group {
                    switch page.icon {
                    case .system(let name):
                        Image(systemName: name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .symbol(let name):
                        Image(symbol: name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .asset(let name):
                        Image(name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .none: EmptyView()
                    }
                }
                .shadow(color: Color(NSColor.black).opacity(0.25), radius: 0.5, y: 0.5)
                .padding(2.5)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(
                    RoundedRectangle(
                        cornerRadius: 5,
                        style: .continuous
                    )
                    .fill((page.baseColor ?? .white).gradient)
                    .shadow(color: Color(NSColor.black).opacity(0.25), radius: 0.5, y: 0.5)
                )
            }
        }
    }
}
