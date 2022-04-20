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
                : Color(nsColor: colorScheme == .dark ? .white : .black)
                    .opacity(colorScheme == .dark ? 0.08 : 0.12)
            )
    }
}

/// The top border for inactive tabs when native-styled tab bar is selected.
struct NativeTabShadow: View {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    let height: CGFloat = 1

    var body: some View {
        Rectangle()
            .foregroundColor(
                Color(nsColor: .black)
                    .opacity(
                        prefs.preferences.general.tabBarStyle == .xcode
                        ? (colorScheme == .dark ? 0.28 : 0.12)
                        : (colorScheme == .dark ? 0.40 : 0.15)
                    )
            )
            .frame(height: height)
    }
}

struct TabBarItem: View {
    @Environment(\.colorScheme)
    var colorScheme

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var isHovering: Bool = false

    @State
    var isHoveringClose: Bool = false

    @State
    var isPressingClose: Bool = false

    @State
    var isAppeared: Bool = false

    var item: WorkspaceClient.FileItem
    var windowController: NSWindowController

    func switchAction() {
        // Only set the `selectedId` when they are not equal to avoid performance issue for now.
        if workspace.selectionState.selectedId != item.id {
            workspace.selectionState.selectedId = item.id
        }
    }

    func closeAction() {
        withAnimation(.easeOut(duration: 0.20)) {
            workspace.closeFileTab(item: item)
        }
    }

    @ObservedObject
    var workspace: WorkspaceDocument

    var isActive: Bool {
        item.id == workspace.selectionState.selectedId
    }

    @ViewBuilder
    var content: some View {
        HStack(spacing: 0.0) {
            TabDivider()
                .opacity(
                    isActive && prefs.preferences.general.tabBarStyle == .xcode ? 0.0 : 1.0
                )
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: item.systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(
                        prefs.preferences.general.fileIconStyle == .color ? item.iconColor : .secondary
                    )
                    .frame(width: 12, height: 12)
                Text(item.url.lastPathComponent)
                    .font(.system(size: 11.0))
                    .lineLimit(1)
            }
            .frame(maxHeight: .infinity) // To max-out the parent (tab bar) area.
            .padding(.horizontal, prefs.preferences.general.tabBarStyle == .native ? 28 : 23)
            .overlay {
                ZStack {
                    if isActive {
                        // Create a hidden button, if the tab is selected
                        // and hide the button in the ZStack.
                        Button(action: closeAction) {
                            Text("").hidden()
                        }
                        .frame(width: 0, height: 0)
                        .padding(0)
                        .opacity(0)
                        .keyboardShortcut("w", modifiers: [.command])
                    }
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
                                .opacity(
                                    isPressingClose
                                    ? 0.29
                                    : (isHoveringClose ? 0.11 : 0)
                                )
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
            .overlay {
                // Only show NativeTabShadow when `tabBarStyle` is native and this tab is not active.
                if prefs.preferences.general.tabBarStyle == .native && !isActive {
                    NativeTabShadow()
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            TabDivider()
                .opacity(
                    isActive && prefs.preferences.general.tabBarStyle == .xcode ? 0.0 : 1.0
                )
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
        .frame(maxHeight: .infinity) // To max-out the parent (tab bar) area.
        .contentShape(Rectangle())
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

    // I am not using Button for wrapping content because Button will potentially
    // have conflict with the inner close Button when the style of this Button is
    // not set to `plain`. And based on the design of CodeEdit, plain style is not
    // an expected choice, so I eventually come up with this solution for now. It
    // is possible to make a customized Button (which may solve the clicking conflict,
    // but I am not sure). I will try that in the future.
    var body: some View {
        Button(action: switchAction) {
            content
        }
        .buttonStyle(TabBarItemButtonStyle())
        .keyboardShortcut(
            workspace.getTabKeyEquivalent(item: item),
            modifiers: [.command]
        )
        .background {
            if prefs.preferences.general.tabBarStyle == .xcode {
                Color(nsColor: isActive ? .selectedControlColor : .clear)
                    .opacity(colorScheme == .dark ? 0.70 : 0.50)
                    .background(
                        // This layer of background is to hide dividers of other tab bar items
                        // because the original background above is translucent (by opacity).
                        Color(nsColor: .controlBackgroundColor)
                    )
                    .animation(.easeInOut(duration: 0.08), value: isHovering)
            } else {
                EffectView(
                    NSVisualEffectView.Material.titlebar,
                    blendingMode: NSVisualEffectView.BlendingMode.withinWindow
                )
                .background(
                    // This background is used to avoid color-split between title bar and tab bar.
                    // The material will tint the color hind, which will result in a color-split.
                    Color(nsColor: .controlBackgroundColor)
                )
                .overlay {
                    if !isActive {
                        ZStack {
                            Color(nsColor: .black)
                                .opacity(colorScheme == .dark ? 0.50 : 0.05)
                            Color(nsColor: colorScheme == .dark ? .white : .black)
                                .opacity(isHovering ? 0.05 : 0.0)
                                .animation(.easeInOut(duration: 0.10), value: isHovering)
                        }
                        .padding(.top, colorScheme == .dark ? 0 : 1)
                        .padding(.horizontal, 1)
                    }
                }
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
