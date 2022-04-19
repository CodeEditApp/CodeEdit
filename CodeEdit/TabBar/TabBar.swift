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
    var colorScheme

    var windowController: NSWindowController

    @ObservedObject
    var workspace: WorkspaceDocument

    var tabBarHeight = 28.0

    @StateObject
    private var prefs: AppPreferencesModel = .shared

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
            // Tab bar items.
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { value in
                    HStack(alignment: .center, spacing: -1) {
                        ForEach(workspace.selectionState.openFileItems, id: \.id) { item in
                            TabBarItem(
                                item: item,
                                windowController: windowController,
                                workspace: workspace
                            )
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
        .background {
            if prefs.preferences.general.tabBarStyle == .native {
                NativeTabShadow()
                    .frame(height: tabBarHeight, alignment: .top)
                    .overlay(
                        Color(nsColor: .black)
                            .opacity(colorScheme == .dark ? 0.50 : 0.05)
                            .padding(.top, 1)
                            .padding(.horizontal, 1)
                    )
            }
        }
        .background {
            if prefs.preferences.general.tabBarStyle == .xcode {
                Color(nsColor: .controlBackgroundColor)
            } else {
                EffectView(
                    NSVisualEffectView.Material.titlebar,
                    blendingMode: NSVisualEffectView.BlendingMode.withinWindow
                )
            }
        }
        .padding(.leading, -1)
    }
}
