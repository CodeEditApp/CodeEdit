//
//  SettingPageView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/31/23.
//

import SwiftUI

struct SettingsPageView: View {
    var page: SettingsPage

    init(_ page: SettingsPage) {
        self.page = page
    }

    var body: some View {
        NavigationLink(value: page) {
            Label {
                Text(page.nameString)
                    .padding(.leading, 2)
            } icon: {
                if let icon = page.icon {
                    Group {
                        switch icon {
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
                        }
                    }
                    .padding(2.5)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 5,
                            style: .continuous
                        )
                        .fill(page.baseColor.gradient)
                    )
                } else {
                    EmptyView()
                }
            }
        }
    }
}
