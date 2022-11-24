//
//  TabBarDivider.swift
//  CodeEdit
//
//  Created by Lingxi Li on 4/22/22.
//

import SwiftUI

/// The vertical divider between tab bar items.
struct TabDivider: View {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    let width: CGFloat = 1

    var body: some View {
        Rectangle()
            .frame(width: width)
            .padding(.vertical, prefs.preferences.general.tabBarStyle == .xcode ? 8 : 0)
            .foregroundColor(
                prefs.preferences.general.tabBarStyle == .xcode
                ? Color(nsColor: colorScheme == .dark ? .white : .black)
                    .opacity(0.12)
                : Color(nsColor: colorScheme == .dark ? .controlColor : .black)
                    .opacity(colorScheme == .dark ? 0.40 : 0.13)
            )
    }
}

/// The top border for tab bar (between tab bar and titlebar).
struct TabBarTopDivider: View {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        ZStack(alignment: .top) {
            if prefs.preferences.general.tabBarStyle == .native {
                // Color background overlay in native style.
                Color(nsColor: .black)
                    .opacity(colorScheme == .dark ? 0.80 : 0.02)
                    .frame(height: prefs.preferences.general.tabBarStyle == .xcode ? 1.0 : 0.8)
                // Shadow of top divider in native style.
                TabBarNativeShadow()
            }
        }
    }
}

/// The bottom border for tab bar (between tab bar and breadcrumbs).
struct TabBarBottomDivider: View {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        Rectangle()
            .foregroundColor(
                prefs.preferences.general.tabBarStyle == .xcode
                ? Color(nsColor: .separatorColor)
                    .opacity(colorScheme == .dark ? 0.80 : 0.40)
                : Color(nsColor: .black)
                    .opacity(colorScheme == .dark ? 0.65 : 0.13)

            )
            .frame(height: prefs.preferences.general.tabBarStyle == .xcode ? 1.0 : 0.8)
    }
}

/// The divider shadow for native tab bar style.
///
/// This is generally used in the top divider of tab bar when tab bar style is set to `native`.
struct TabBarNativeShadow: View {
    let shadowColor = Color(nsColor: .shadowColor)

    var body: some View {
        LinearGradient(
            colors: [
                shadowColor.opacity(0.18),
                shadowColor.opacity(0.06),
                shadowColor.opacity(0.03),
                shadowColor.opacity(0.01),
                shadowColor.opacity(0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 3.8)
        .opacity(0.70)
    }
}
