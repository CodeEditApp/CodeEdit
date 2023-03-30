//
//  WorkspaceTabGroupView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct WorkspaceTabGroupView: View {
    @ObservedObject
    var tabGroup: TabGroupData

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @FocusState.Binding
    var focus: TabGroupData?

    @EnvironmentObject
    private var tabManager: TabManager

    var body: some View {
        VStack {
            if let selected = tabGroup.selected {
                WorkspaceCodeFileView(file: selected)
                    .transformEnvironment(\.edgeInsets) { insets in
                        insets.top += TabBarView.height + PathBarView.height + 1 + 1
                    }
            } else {
                VStack {
                    Spacer()
                    Text("No Editor")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 0)
                        .clipped()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    tabManager.activeTabGroup = tabGroup
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                TabBarView()
                    .id("TabBarView" + tabGroup.id.uuidString)
                    .environmentObject(tabGroup)
                    .tabBarStyle(prefs.preferences.general.tabBarStyle)
                Divider()
                if let file = tabGroup.selected {
                    PathBarView(file: file) { [weak tabGroup] newFile in
                        if let index = tabGroup?.tabs.firstIndex(of: file) {
                            tabGroup?.openTab(item: newFile, at: index)
                        }
                    }
                    Divider()
                }
            }
            .environment(\.isActiveTabGroup, tabGroup == tabManager.activeTabGroup)
            .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))
        }
        .focused($focus, equals: tabGroup)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CodeEditor.didBeginEditing"))) { _ in
            tabGroup.temporaryTab = nil
        }
    }
}
