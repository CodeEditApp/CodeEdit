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

    @FocusState var isFocused

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
                        print("Opening \(newFile.fileName)")

                        let index = tabgroup.files.firstIndex(of: file)
                        if let index {
                            tabgroup.openTab(item: newFile, at: index)
                        }
                    }
                    Divider()
                }
            }
            .environment(\.controlActiveState, tabgroup == tabManager.activeTabGroup ? .key : .inactive)
            .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))
        }
        .focused($isFocused)
        .onChange(of: isFocused) { focused in
            if focused {
                tabManager.activeTabGroup = tabgroup
            }
        }
    }
}
