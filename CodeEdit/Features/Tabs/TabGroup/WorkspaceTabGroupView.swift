//
//  WorkspaceTabGroupView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct WorkspaceTabGroupView: View {
    @ObservedObject
    var tabgroup: TabGroupData

    @FocusState.Binding
    var focus: TabGroupData?

    @EnvironmentObject
    private var tabManager: TabManager

    var body: some View {
        VStack {
            if let selected = tabgroup.selected {
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
                    tabManager.activeTabGroup = tabgroup
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                TabBarView()
                    .id("TabBarView" + tabgroup.id.uuidString)
                    .environmentObject(tabgroup)

                Divider()
                if let file = tabgroup.selected {
                    PathBarView(file: file) { [weak tabgroup] newFile in
                        if let index = tabgroup?.tabs.firstIndex(of: file) {
                            tabgroup?.openTab(item: newFile, at: index)
                        }
                    }
                    Divider()
                }
            }
            .environment(\.isActiveTabGroup, tabgroup == tabManager.activeTabGroup)
            .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))
        }
        .focused($focus, equals: tabgroup)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CodeEditor.didBeginEditing"))) { _ in
            tabgroup.temporaryTab = nil
        }
    }
}
