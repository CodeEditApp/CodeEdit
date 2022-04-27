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
    @Environment(\.colorScheme) var colorScheme

    @Environment(\.controlActiveState) private var activeState

    var windowController: NSWindowController

    @ObservedObject
    var workspace: WorkspaceDocument

    var tabBarHeight = 28.0

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var expectedTabWidth: CGFloat = 0

    @State
    var isHoveringOverTabs: Bool = false

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
            .frame(maxHeight: .infinity) // Fill out vertical spaces.
            if prefs.preferences.general.tabBarStyle == .native {
                TabDivider()
                    .opacity(0.7)
            }
            // Tab bar items.
            GeometryReader { geometryReader in
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { value in
                        HStack(
                            alignment: .center,
                            spacing: -1
                        ) {
                            ForEach(workspace.selectionState.openFileItems, id: \.id) { item in
                                TabBarItem(
                                    expectedWidth: $expectedTabWidth,
                                    item: item,
                                    windowController: windowController,
                                    workspace: workspace
                                )
//                                .transition(.offset(x: 0, y: 0))
                            }
                        }
                        .padding(.leading, prefs.preferences.general.tabBarStyle == .native ? -1 : 0)
                        .onAppear {
                            expectedTabWidth = max(
                                // Equally divided size of a native tab.
                                (geometryReader.size.width + 1) /
                                    CGFloat(workspace.selectionState.openFileItems.count) + 1,
                                // Min size of a native tab.
                                CGFloat(130)
                            )

                            value.scrollTo(self.workspace.selectionState.selectedId)
                        }
                        .onChange(of: workspace.selectionState.openFileItems.count) { tabCount in
                            if !isHoveringOverTabs {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    expectedTabWidth = max(
                                        // Equally divided size of a native tab.
                                        (geometryReader.size.width + 1) / CGFloat(tabCount) + 1,
                                        // Min size of a native tab.
                                        CGFloat(130)
                                    )
                                }
                            }
                        }
                        .onChange(of: geometryReader.size.width) { newWidth in
                            expectedTabWidth = max(
                                // Equally divided size of a native tab.
                                (newWidth + 1) /
                                    CGFloat(workspace.selectionState.openFileItems.count) + 1,
                                // Min size of a native tab.
                                CGFloat(130)
                            )
                        }
                        .onHover { isHovering in
                            isHoveringOverTabs = isHovering
                            if !isHovering {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    expectedTabWidth = max(
                                        // Equally divided size of a native tab.
                                        (geometryReader.size.width + 1) /
                                            CGFloat(workspace.selectionState.openFileItems.count) + 1,
                                        // Min size of a native tab.
                                        CGFloat(130)
                                    )
                                }
                            }
                        }
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
                TabBarNativeBackgroundInactive()
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
