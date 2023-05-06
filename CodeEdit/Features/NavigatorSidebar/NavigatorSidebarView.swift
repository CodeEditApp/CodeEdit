//
//  NavigatorSidebarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebarView: View {
    @ObservedObject
    private var workspace: WorkspaceDocument

    @AppSettings(\.general.useSidebarVibrancyEffect) var useSidebarVibrancyEffect: Bool
    @AppSettings(\.theme.allowThemeWindowTinting) var allowThemeWindowTinting: Bool

    @State
    private var selectedTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!

    @State
    private var selection: Int = 0

    @StateObject
    private var themeModel: ThemeModel = .shared

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    @AppSettings(\.general.navigatorTabBarPosition) var sidebarPosition: SettingsData.SidebarTabBarPosition

    var body: some View {
        VStack {
            switch selection {
            case 0:
                ProjectNavigatorView()
            case 1:
                SourceControlNavigatorView()
            case 2:
                FindNavigatorView()
            default:
                Spacer()
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            if sidebarPosition == .side {
                NavigatorSidebarTabBar(selection: $selection, position: sidebarPosition)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if sidebarPosition == .top {
                NavigatorSidebarTabBar(selection: $selection, position: sidebarPosition)
            } else {
                Divider()
            }
        }
        .environmentObject(workspace)
        .background(
            allowThemeWindowTinting
            ? Color(nsColor: selectedTheme.editor.background.nsColor).opacity(0.5).ignoresSafeArea()
            : nil
        )
        .background(
            !useSidebarVibrancyEffect
            ? EffectView(.windowBackground, blendingMode: .withinWindow).ignoresSafeArea()
            : nil
        )
        .onChange(of: themeModel.selectedTheme) { newValue in
            guard let theme = newValue else { return }
            self.selectedTheme = theme
        }
    }
}
