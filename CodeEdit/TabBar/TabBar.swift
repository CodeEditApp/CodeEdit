//
//  TabBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences
import CodeEditUI

struct TabBar: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    private let windowController: NSWindowController

    @ObservedObject
    private var workspace: WorkspaceDocument

    private let tabBarHeight = 28.0

    @StateObject
    private var prefs: AppPreferencesModel = .shared
    // TabBar(windowController: windowController, workspace: workspace)
    init(windowController: NSWindowController, workspace: WorkspaceDocument) {
        self.windowController = windowController
        self.workspace = workspace
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Tab bar navigation control.
            // TODO: Real functionality of tab bar navigation control and their stated foreground color.
            HStack(spacing: 10) {
                Button(
                    action: { /* TODO */ },
                    label: {
                        Image(systemName: "chevron.left")
                    }
                )
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                Button(
                    action: { /* TODO */ },
                    label: {
                        Image(systemName: "chevron.right")
                    }
                )
                .foregroundColor(.secondary.opacity(0.5))
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 11)
            .opacity(activeState != .inactive ? 1.0 : 0.5)
            // Tab bar items.
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { value in
                    HStack(alignment: .center, spacing: -1) {
                        ForEach(workspace.selectionState.openedTabs, id: \.id) { id in
                            if let item = self.workspace.selectionState.getItemByTab(id: id) {
                                TabBarItem(
                                    item: item,
                                    windowController: windowController,
                                    workspace: workspace
                                )
                            }
                        }
                    }
                    .onAppear {
                        value.scrollTo(self.workspace.selectionState.selectedId)
                    }
                }
            }
            // TODO: Tab bar tools (e.g. split view).
        }
        .frame(height: tabBarHeight)
        .overlay(alignment: .top) {
            // When tab bar style is `xcode`, we put the top divider as an overlay.
            if prefs.preferences.general.tabBarStyle == .xcode {
                TabBarTopDivider()
            }
        }
        .background {
            if prefs.preferences.general.tabBarStyle == .xcode {
                Color(nsColor: .controlBackgroundColor)
            } else {
                ZStack(alignment: .top) {
                    Color(nsColor: .black)
                        .opacity(colorScheme == .dark ? 0.45 : 0.05)
                    // When tab bar style is `native`, we put the top divider beneath tabs.
                    TabBarTopDivider()
                }
            }
        }
        .background {
            if prefs.preferences.general.tabBarStyle == .xcode {
                EffectView(
                    NSVisualEffectView.Material.titlebar,
                    blendingMode: NSVisualEffectView.BlendingMode.withinWindow
                )
                // Set bottom padding to avoid material overlapping in bar.
                .padding(.bottom, tabBarHeight)
                .edgesIgnoringSafeArea(.top)
            } else {
                EffectView(
                    NSVisualEffectView.Material.titlebar,
                    blendingMode: NSVisualEffectView.BlendingMode.withinWindow
                )
                .background(Color(nsColor: .controlBackgroundColor))
                .edgesIgnoringSafeArea(.top)
            }
        }
        .padding(.leading, -1)
    }
}
