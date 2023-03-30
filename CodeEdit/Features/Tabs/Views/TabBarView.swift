//
//  TabBarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol and Lingxi Li on 17.03.22.
//

import SwiftUI

struct TabBarView: View {

    @Environment(\.modifierKeys) var modifierKeys

    typealias TabID = WorkspaceClient.FileItem.ID

    /// The height of tab bar.
    /// I am not making it a private variable because it may need to be used in outside views.
    static let height = 28.0

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    /// The workspace document.
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @EnvironmentObject
    private var tabManager: TabManager

    @EnvironmentObject
    private var tabGroup: TabGroupData

    @Environment(\.splitEditor) var splitEditor

    /// The app preference.
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Tab bar navigation control.
            leadingAccessories
            // Tab bar items.
            TabBarTabs()
            // Tab bar tools (e.g. split view).
            trailingAccessories
        }
        .frame(height: TabBarView.height)
        .overlay(alignment: .top) {
            // When tab bar style is `xcode`, we put the top divider as an overlay.
            if prefs.preferences.general.tabBarStyle == .xcode {
                TabBarTopDivider()
            }
        }
        .background {
            if prefs.preferences.general.tabBarStyle == .native {
                TabBarNativeMaterial()
                    .edgesIgnoringSafeArea(.top)
            } else {
                EffectView(.headerView)
            }
        }
        .padding(.leading, -1)
    }

    // MARK: Accessories

    private var leadingAccessories: some View {
        HStack(spacing: 2) {
            if tabManager.tabGroups.findSomeTabGroup(except: tabGroup) != nil {
                TabBarAccessoryIcon(
                    icon: .init(systemName: "multiply"),
                    action: { [weak tabGroup] in
                        tabGroup?.close()
                        if tabManager.activeTabGroup == tabGroup {
                            tabManager.activeTabGroupHistory.removeAll { $0() == nil || $0() == tabGroup }
                            tabManager.activeTabGroup = tabManager.activeTabGroupHistory.removeFirst()()!
                        }
                        tabManager.flatten()
                    }
                )
                .help("Close Tab Group")

                Divider()
                    .frame(height: 10)
                    .padding(.horizontal, 4)
            }

            Group {
                Menu {
                    ForEach(
                        Array(tabGroup.history.dropFirst(tabGroup.historyOffset+1).enumerated()),
                        id: \.offset
                    ) { index, tab in
                        Button {
                            tabManager.activeTabGroup = tabGroup
                            tabGroup.historyOffset += index + 1
                        } label: {
                            HStack {
                                tab.icon
                                Text(tab.fileName)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .controlSize(.regular)
                        .opacity(
                            tabGroup.historyOffset == tabGroup.history.count-1 || tabGroup.history.isEmpty
                            ? 0.5 : 1.0
                        )
                } primaryAction: {
                    tabManager.activeTabGroup = tabGroup
                    tabGroup.historyOffset += 1
                }
                .disabled(tabGroup.historyOffset == tabGroup.history.count-1 || tabGroup.history.isEmpty)
                .help("Navigate back")

                Menu {
                    ForEach(
                        Array(tabGroup.history.prefix(tabGroup.historyOffset).reversed().enumerated()),
                        id: \.offset
                    ) { index, tab in
                        Button {
                            tabManager.activeTabGroup = tabGroup
                            tabGroup.historyOffset -= index + 1
                        } label: {
                            HStack {
                                tab.icon
                                Text(tab.fileName)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .controlSize(.regular)
                        .opacity(tabGroup.historyOffset == 0 ? 0.5 : 1.0)
                } primaryAction: {
                    tabManager.activeTabGroup = tabGroup
                    tabGroup.historyOffset -= 1
                }
                .disabled(tabGroup.historyOffset == 0)
                .help("Navigate forward")
            }
            .controlSize(.small)
            .font(TabBarAccessoryIcon.iconFont)
            .frame(height: TabBarView.height - 2)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .foregroundColor(.secondary)
        .buttonStyle(.plain)
        .padding(.horizontal, 7)
        .opacity(activeState != .inactive ? 1.0 : 0.5)
        .frame(maxHeight: .infinity) // Fill out vertical spaces.
        .background {
            if prefs.preferences.general.tabBarStyle == .native {
                TabBarAccessoryNativeBackground(dividerAt: .trailing)
            }
        }
    }

    private var trailingAccessories: some View {
        HStack(spacing: 2) {
            TabBarAccessoryIcon(
                icon: .init(systemName: "ellipsis.circle"),
                action: {} // TODO: Implement
            )
            .foregroundColor(.secondary)
            .buttonStyle(.plain)
            .help("Options")
            TabBarAccessoryIcon(
                icon: .init(systemName: "arrow.left.arrow.right.square"),
                action: {} // TODO: Implement
            )
            .foregroundColor(.secondary)
            .buttonStyle(.plain)
            .help("Enable Code Review")
            splitviewButton
        }
        .padding(.horizontal, 7)
        .opacity(activeState != .inactive ? 1.0 : 0.5)
        .frame(maxHeight: .infinity) // Fill out vertical spaces.
        .background {
            if prefs.preferences.general.tabBarStyle == .native {
                TabBarAccessoryNativeBackground(dividerAt: .leading)
            }
        }
    }

    var splitviewButton: some View {
        Group {
            switch (tabGroup.parent?.axis, modifierKeys.contains(.option)) {
            case (.horizontal, true), (.vertical, false):
                TabBarAccessoryIcon(icon: Image(systemName: "square.split.1x2")) {
                    split(edge: .bottom)
                }
                .help("Split Vertically")

            case (.vertical, true), (.horizontal, false):
                TabBarAccessoryIcon(icon: Image(systemName: "square.split.2x1")) {
                    split(edge: .trailing)
                }
                .help("Split Horizontally")

            default:
                EmptyView()
            }
        }
        .foregroundColor(.secondary)
        .buttonStyle(.plain)
    }

    func split(edge: Edge) {
        let newTabGroup: TabGroupData
        if let tab = tabGroup.selected {
            newTabGroup = .init(files: [tab])
        } else {
            newTabGroup = .init()
        }
        splitEditor(edge, newTabGroup)
        tabManager.activeTabGroup = newTabGroup
    }

}
// swiftlint:enable type_body_length
