//
//  WorkspaceTabGroupView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct WorkspaceTabGroupView: View {
    @ObservedObject var tabgroup: TabGroupData

    @EnvironmentObject var tabManager: TabManager

    @FocusState.Binding var focus: TabGroupData?

    @FocusState var focused

    var body: some View {
        VStack {
            if let selected = tabgroup.selected {
                WorkspaceCodeFileView(file: selected)
                    .transformEnvironment(\.edgeInsets) { insets in
                        insets.top += TabBarView.height + BreadcrumbsView.height + 1 + 1
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
                    BreadcrumbsView(file: file) { newFile in
                        let index = tabgroup.tabs.firstIndex(of: file)
                        if let index {
                            tabgroup.openTab(item: newFile, at: index)
                        }
                    }
                    Divider()
                }
            }
            .environment(\.isActiveTabGroup, tabgroup == tabManager.activeTabGroup)
            .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))
        }
        .environmentObject(tabgroup)
//        .focused($focus, equals: tabgroup)
        .focused($focused)

//        .focused($focus, equals: tabgroup)
        
//        .focused($isFocused)
        .task(id: tabManager.activeTabGroup) {
            focused = tabManager.activeTabGroup == tabgroup
            print("Set Focus to \(focused)")
        }
        .onChange(of: focused) { focused in
            print("Focus change for \(tabgroup.selected?.fileName)", focused)
            if focused {
                tabManager.activeTabGroup = tabgroup
            } else {
                print("Lost focus")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CodeEditor.didBeginEditing"))) { _ in
            print("Not temporary anymore")
            tabgroup.temporaryTab = nil
        }
    }
}
