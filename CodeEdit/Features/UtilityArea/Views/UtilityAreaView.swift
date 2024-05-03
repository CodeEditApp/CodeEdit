//
//  UtilityAreaView.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct UtilityAreaView: View {
    @AppSettings(\.theme.matchAppearance)
    private var matchAppearance

    @AppSettings(\.terminal.darkAppearance)
    private var darkAppearance

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject private var model: UtilityAreaViewModel

    @StateObject private var themeModel: ThemeModel = .shared

    @State var selection: UtilityAreaTab? = .terminal

    var body: some View {
        VStack(spacing: 0) {
            if let selection {
                selection
            } else {
                Text("Tab not found")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            HStack(spacing: 0) {
                AreaTabBar(items: $model.tabItems, selection: $selection, position: .side)
                Divider()
                    .overlay(Color(nsColor: colorScheme == .dark ? .black : .clear))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 5) {
                Divider()
                HStack(spacing: 0) {
                    StatusBarMaximizeButton()
                }
            }
            .colorScheme(
                model.selectedTerminals.isEmpty
                ? colorScheme
                : matchAppearance && darkAppearance
                ? themeModel.selectedDarkTheme?.appearance == .dark ? .dark : .light
                : themeModel.selectedTheme?.appearance == .dark ? .dark : .light
            )
            .padding(.horizontal, 5)
            .padding(.vertical, 8)
            .frame(maxHeight: 27)
        }
    }
}
