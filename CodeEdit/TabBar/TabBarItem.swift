//
//  TabBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences
import CodeEditUI

struct TabBarItem: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var isHovering: Bool = false

    @State
    private var isHoveringClose: Bool = false

    @State
    private var isPressingClose: Bool = false

    @State
    private var isAppeared: Bool = false

    @Binding
    private var expectedWidth: CGFloat

    @ObservedObject
    var workspace: WorkspaceDocument

    private var item: WorkspaceClient.FileItem

    private var windowController: NSWindowController

    var isActive: Bool {
        item.id == workspace.selectionState.selectedId
    }

    private func switchAction() {
        // Only set the `selectedId` when they are not equal to avoid performance issue for now.
        if workspace.selectionState.selectedId != item.id {
            workspace.selectionState.selectedId = item.id
        }
    }

    func closeAction() {
        if prefs.preferences.general.tabBarStyle == .native {
            isAppeared = false
        }
        withAnimation(.easeOut(duration: 0.20)) {
            workspace.closeFileTab(item: item)
        }
    }

    init(
        expectedWidth: Binding<CGFloat>,
        item: WorkspaceClient.FileItem,
        windowController: NSWindowController,
        workspace: WorkspaceDocument
    ) {
        self._expectedWidth = expectedWidth
        self.item = item
        self.windowController = windowController
        self.workspace = workspace
    }

    @ViewBuilder
    var content: some View {
        HStack(spacing: 0.0) {
            TabDivider()
                .opacity(isActive && prefs.preferences.general.tabBarStyle == .xcode ? 0.0 : 1.0)
            // Tab content (icon and text).
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: item.systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(
                        prefs.preferences.general.fileIconStyle == .color && activeState != .inactive
                        ? item.iconColor
                        : .secondary
                    )
                    .frame(width: 12, height: 12)
                Text(item.url.lastPathComponent)
                    .font(.system(size: 11.0))
                    .lineLimit(1)
            }
            .frame(
                // To horizontally max-out the given width area ONLY in native tab bar style.
                maxWidth: prefs.preferences.general.tabBarStyle == .native ? .infinity : nil,
                // To max-out the parent (tab bar) area.
                maxHeight: .infinity
            )
            .padding(.horizontal, prefs.preferences.general.tabBarStyle == .native ? 28 : 23)
            .overlay {
                ZStack {
                    if isActive {
                        // Close Tab Shortcut:
                        // Using an invisible button to contain the keyboard shortcut is simply
                        // because the keyboard shortcut has an unexpected bug when working with
                        // custom buttonStyle. This is an workaround and it works as expected.
                        Button(
                            action: closeAction,
                            label: { EmptyView() }
                        )
                        .frame(width: 0, height: 0)
                        .padding(0)
                        .opacity(0)
                        .keyboardShortcut("w", modifiers: [.command])
                    }
                    // Switch Tab Shortcut:
                    // Using an invisible button to contain the keyboard shortcut is simply
                    // because the keyboard shortcut has an unexpected bug when working with
                    // custom buttonStyle. This is an workaround and it works as expected.
                    Button(
                        action: switchAction,
                        label: { EmptyView() }
                    )
                    .frame(width: 0, height: 0)
                    .padding(0)
                    .opacity(0)
                    .keyboardShortcut(
                        workspace.getTabKeyEquivalent(item: item),
                        modifiers: [.command]
                    )
                    .background(.blue)
                    // Close button.
                    Button(action: closeAction) {
                        if prefs.preferences.general.tabBarStyle == .xcode {
                            Image(systemName: "xmark")
                                .font(.system(size: 11.2, weight: .regular, design: .rounded))
                                .frame(width: 16, height: 16)
                                .foregroundColor(
                                    isActive
                                    ? (
                                        colorScheme == .dark
                                        ? .primary
                                        : Color(nsColor: .controlAccentColor)
                                    )
                                    : .secondary.opacity(0.80)
                                )
                        } else {
                            Image(systemName: "xmark")
                                .font(.system(size: 9.5, weight: .medium, design: .rounded))
                                .frame(width: 16, height: 16)
                        }
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(isPressingClose ? .primary : .secondary)
                    .background(
                        colorScheme == .dark
                        ? Color(nsColor: .white).opacity(isPressingClose ? 0.32 : isHoveringClose ? 0.18 : 0)
                        : (
                            prefs.preferences.general.tabBarStyle == .xcode
                            ? Color(nsColor: isActive ? .controlAccentColor : .black)
                                .opacity(
                                    isPressingClose
                                    ? 0.25
                                    : (isHoveringClose ? (isActive ? 0.10 : 0.06) : 0)
                                )
                            : Color(nsColor: .black)
                                .opacity(isPressingClose ? 0.29 : (isHoveringClose ? 0.11 : 0))
                        )
                    )
                    .cornerRadius(2)
                    .accessibilityLabel(Text("Close"))
                    .onHover { hover in
                        isHoveringClose = hover
                    }
                    .pressAction {
                        isPressingClose = true
                    } onRelease: {
                        isPressingClose = false
                    }
                    .opacity(isHovering ? 1 : 0)
                    .animation(.easeInOut(duration: 0.08), value: isHovering)
                    .padding(.leading, prefs.preferences.general.tabBarStyle == .xcode ? 3.5 : 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(
                // Inactive states for tab bar item content.
                activeState != .inactive
                ? 1.0
                : (
                    isActive
                    ? (prefs.preferences.general.tabBarStyle == .xcode ? 0.6 : 0.35)
                    : (prefs.preferences.general.tabBarStyle == .xcode ? 0.4 : 0.55)
                )
            )
            TabDivider()
                .opacity(isActive && prefs.preferences.general.tabBarStyle == .xcode ? 0.0 : 1.0)
        }
        .overlay(alignment: .top) {
            // Only show NativeTabShadow when `tabBarStyle` is native and this tab is not active.
            TabBarTopDivider()
                .opacity(prefs.preferences.general.tabBarStyle == .native && !isActive ? 1 : 0)
        }
        .foregroundColor(
            isActive
            ? (
                prefs.preferences.general.tabBarStyle == .xcode && colorScheme != .dark
                ? Color(nsColor: .controlAccentColor)
                : .primary
            )
            : (
                prefs.preferences.general.tabBarStyle == .xcode
                ? .primary
                : .secondary
            )
        )
        .frame(maxHeight: .infinity) // To vertically max-out the parent (tab bar) area.
        .contentShape(Rectangle()) // Make entire area clickable.
        .onHover { hover in
            isHovering = hover
            DispatchQueue.main.async {
                if hover {
                    NSCursor.arrow.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }

    var body: some View {
        Button(
            action: switchAction,
            label: { content }
        )
        .buttonStyle(TabBarItemButtonStyle())
        .background {
            if prefs.preferences.general.tabBarStyle == .xcode {
                Color(nsColor: isActive ? .selectedControlColor : .clear)
                    .opacity(
                        colorScheme == .dark
                        ? (activeState != .inactive ? 0.70 : 0.50)
                        : (activeState != .inactive ? 0.50 : 0.35)
                    )
                    .background(
                        // This layer of background is to hide dividers of other tab bar items
                        // because the original background above is translucent (by opacity).
                        Color(nsColor: .controlBackgroundColor)
                    )
                    .animation(.easeInOut(duration: 0.08), value: isHovering)
            } else {
                TabBarNativeMaterial()
                ZStack {
                    // Native inactive tab background dim.
                    TabBarNativeInactiveBackgroundColor()
                    // Native inactive tab hover state.
                    Color(nsColor: colorScheme == .dark ? .white : .black)
                        .opacity(isHovering ? (colorScheme == .dark ? 0.08 : 0.05) : 0.0)
                        .animation(.easeInOut(duration: 0.10), value: isHovering)
                }
                .padding(.horizontal, 1)
                .opacity(isActive ? 0 : 1)
            }
        }
        .padding(
            // This padding is to avoid background color overlapping with top divider.
            .top, prefs.preferences.general.tabBarStyle == .xcode ? 1 : 0
        )
        .offset(
            x: isAppeared || prefs.preferences.general.tabBarStyle == .native ? 0 : -14,
            y: 0
        )
        .opacity(isAppeared ? 1.0 : 0.0)
        .zIndex(isActive ? 1 : 0)
        .frame(
            width: (
                // Constrain the width of tab bar item for native tab style only.
                prefs.preferences.general.tabBarStyle == .native
                ? max(expectedWidth.isFinite ? expectedWidth : 0, 0)
                : nil
            )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.20)) {
                isAppeared = true
            }
        }
        .id(item.id)
        .contextMenu {
            Button("Close Tab") {
                withAnimation {
                    workspace.closeFileTab(item: item)
                }
            }
            Button("Close Other Tabs") {
                withAnimation {
                    workspace.closeFileTab(where: { $0.id != item.id })
                }
            }
            Button("Close Tabs to the Right") {
                withAnimation {
                    workspace.closeFileTabs(after: item)
                }
            }
        }
    }
}

fileprivate extension WorkspaceDocument {
    func getTabKeyEquivalent(item: WorkspaceClient.FileItem) -> KeyEquivalent {
        for counter in 0..<9 where self.selectionState.openFileItems.count > counter &&
        self.selectionState.openFileItems[counter].fileName == item.fileName {
            return KeyEquivalent.init(
                Character.init("\(counter + 1)")
            )
        }
        return "0"
    }
}

private struct TabBarItemButtonStyle: ButtonStyle {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed && prefs.preferences.general.tabBarStyle == .xcode
                ? (colorScheme == .dark ? .white.opacity(0.08) : .black.opacity(0.09))
                : .clear
            )
    }
}
