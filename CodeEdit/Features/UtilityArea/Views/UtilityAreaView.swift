//
//  UtilityAreaView.swift
//  CodeEdit
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

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @StateObject private var themeModel: ThemeModel = .shared

    var body: some View {
        VStack(spacing: 0) {
            if let selectedTab = utilityAreaViewModel.selectedTab {
                selectedTab
            } else {
                Text("Tab not found")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            HStack(spacing: 0) {
                AreaTabBar(
                    items: $utilityAreaViewModel.tabItems,
                    selection: $utilityAreaViewModel.selectedTab,
                    position: .side
                )
                Divider()
                    .overlay(Color(nsColor: colorScheme == .dark ? .black : .clear))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Utility Area")
    }
}
