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

    @State
    var expectedTabWidth: CGFloat = 0

    /// This state is used to detect if the mouse is hovering over tabs.
    /// If it is true, then we do not update the expected tab width immediately.
    @State
    var isHoveringOverTabs: Bool = false

    private func updateExpectedTabWidth(proxy: GeometryProxy) {
        expectedTabWidth = max(
            // Equally divided size of a native tab.
            (proxy.size.width + 1) / CGFloat(workspace.selectionState.openFileItems.count) + 1,
            // Min size of a native tab.
            CGFloat(140)
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Tab bar navigation control.
            HStack(spacing: 10) {
                TabBarAccessoryIcon(
                    icon: .init(systemName: "chevron.left"),
                    action: { /* TODO */ }
                )
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                TabBarAccessoryIcon(
                    icon: .init(systemName: "chevron.right"),
                    action: { /* TODO */ }
                )
                .foregroundColor(.secondary.opacity(0.5))
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 11)
            .opacity(activeState != .inactive ? 1.0 : 0.5)
            .frame(maxHeight: .infinity) // Fill out vertical spaces.
            if prefs.preferences.general.tabBarStyle == .native {
                TabDivider()
            }
            // Tab bar items.
            GeometryReader { geometryProxy in
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
                            }
                        }
                        // This padding is to hide dividers at two ends under the accessory view divider.
                        .padding(.horizontal, prefs.preferences.general.tabBarStyle == .native ? -1 : 0)
                        .onAppear {
                            updateExpectedTabWidth(proxy: geometryProxy)
                            value.scrollTo(self.workspace.selectionState.selectedId)
                        }
                        .onChange(of: workspace.selectionState.openFileItems.count) { _ in
                            // Only update the expected width when user is not hovering over tabs.
                            // This should give users a better experience on closing multiple tabs continuously.
                            if !isHoveringOverTabs {
                                withAnimation(.easeOut(duration: 0.20)) {
                                    updateExpectedTabWidth(proxy: geometryProxy)
                                }
                            }
                        }
                        .onChange(of: geometryProxy.size.width) { _ in
                            updateExpectedTabWidth(proxy: geometryProxy)
                        }
                        .onHover { isHovering in
                            isHoveringOverTabs = isHovering
                            // When user is not hovering anymore, update the expected width immediately.
                            if !isHovering {
                                withAnimation(.easeOut(duration: 0.20)) {
                                    updateExpectedTabWidth(proxy: geometryProxy)
                                }
                            }
                        }
                    }
                }
            }
            if prefs.preferences.general.tabBarStyle == .native {
                TabDivider()
            }
            // Tab bar tools (e.g. split view).
            HStack(spacing: 10) {
                TabBarAccessoryIcon(
                    icon: .init(systemName: "ellipsis.circle"),
                    action: { /* TODO */ }
                )
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                TabBarAccessoryIcon(
                    icon: .init(systemName: "arrow.left.arrow.right.square"),
                    action: { /* TODO */ }
                )
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
                TabBarAccessoryIcon(
                    icon: .init(systemName: "square.split.2x1"),
                    action: { /* TODO */ }
                )
                .foregroundColor(.secondary)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 11)
            .opacity(activeState != .inactive ? 1.0 : 0.5)
            .frame(maxHeight: .infinity) // Fill out vertical spaces.
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
                TabBarNativeInactiveBackground()
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
                TabBarNativeMaterial()
                    .edgesIgnoringSafeArea(.top)
            }
        }
        .padding(.leading, -1)
    }
}

/// Accessory icon's view for tab bar.
struct TabBarAccessoryIcon: View {
    /// Unifies icon font for tab bar accessories.
    static private let iconFont = Font.system(size: 14, weight: .regular, design: .default)

    private let icon: Image
    private let action: () -> Void

    init(icon: Image, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(
            action: action,
            label: { icon.font(TabBarAccessoryIcon.iconFont) }
        )
    }
}
